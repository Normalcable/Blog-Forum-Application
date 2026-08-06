import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // AUTH API
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': displayName,
        'username': displayName.toLowerCase().replaceAll(' ', '_'),
      },
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // STORAGE API
  Future<List<String>> uploadImages(List<XFile> files, String bucket) async {
    final List<String> urls = [];
    final userId = currentUser?.id ?? 'guest';

    for (final file in files) {
      try {
        final bytes = await file.readAsBytes();
        final extension = file.name.split('.').last;
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_${urls.length}.$extension';

        await _client.storage.from(bucket).uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(contentType: 'image/$extension'),
            );

        final publicUrl = _client.storage.from(bucket).getPublicUrl(fileName);
        urls.add(publicUrl);
      } catch (e) {
        // Skip failed individual upload
      }
    }
    return urls;
  }

  Future<String?> uploadAvatar(XFile file) async {
    final urls = await uploadImages([file], 'avatars');
    return urls.isNotEmpty ? urls.first : null;
  }

  // USER PROFILE API
  Future<UserModel?> getProfile(String userId) async {
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res == null) return null;

      return UserModel(
        id: res['id'],
        displayName: res['display_name'] ?? 'Discourse User',
        username: res['username'] ?? 'user',
        bio: res['bio'] ?? '',
        avatarUrl: res['avatar_url'],
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String displayName,
    required String username,
    required String bio,
    String? avatarUrl,
  }) async {
    final updates = {
      'display_name': displayName,
      'username': username,
      'bio': bio,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (avatarUrl != null) {
      updates['avatar_url'] = avatarUrl;
    }

    await _client.from('profiles').update(updates).eq('id', userId);
  }

  // POSTS API WITH PAGINATION
  Future<List<PostModel>> fetchPosts({int offset = 0, int limit = 10}) async {
    try {
      final res = await _client
          .from('posts')
          .select('''
            *,
            profiles!posts_author_id_fkey (display_name, username, avatar_url),
            post_likes (user_id)
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final String? currentUserId = currentUser?.id;

      return (res as List).map((map) {
        final profile = map['profiles'] ?? {};
        final likes = (map['post_likes'] as List? ?? []);
        final isLiked = currentUserId != null &&
            likes.any((l) => l['user_id'] == currentUserId);

        return PostModel(
          id: map['id'],
          authorId: map['author_id'],
          authorName: profile['display_name'] ?? 'Anonymous',
          authorHandle: '@${profile['username'] ?? 'user'}',
          authorAvatarUrl: profile['avatar_url'],
          title: map['title'],
          content: map['content'],
          community: map['community'] ?? 'general',
          tags: List<String>.from(map['tags'] ?? []),
          imageUrls: List<String>.from(map['image_urls'] ?? []),
          createdAt: DateTime.parse(map['created_at']),
          likesCount: likes.length,
          isLiked: isLiked,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PostModel?> createPost({
    required String title,
    required String content,
    required String community,
    required List<String> tags,
    List<String> imageUrls = const [],
  }) async {
    if (currentUser == null) return null;

    final res = await _client.from('posts').insert({
      'author_id': currentUser!.id,
      'title': title,
      'content': content,
      'community': community,
      'tags': tags,
      'image_urls': imageUrls,
    }).select('''
      *,
      profiles!posts_author_id_fkey (display_name, username, avatar_url)
    ''').single();

    final profile = res['profiles'] ?? {};

    return PostModel(
      id: res['id'],
      authorId: res['author_id'],
      authorName: profile['display_name'] ?? 'Discourse User',
      authorHandle: '@${profile['username'] ?? 'user'}',
      authorAvatarUrl: profile['avatar_url'],
      title: res['title'],
      content: res['content'],
      community: res['community'] ?? 'general',
      tags: List<String>.from(res['tags'] ?? []),
      imageUrls: List<String>.from(res['image_urls'] ?? []),
      createdAt: DateTime.parse(res['created_at']),
      likesCount: 0,
      isLiked: false,
    );
  }

  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    required String community,
    required List<String> tags,
    List<String>? imageUrls,
  }) async {
    final Map<String, dynamic> updates = {
      'title': title,
      'content': content,
      'community': community,
      'tags': tags,
    };
    if (imageUrls != null) {
      updates['image_urls'] = imageUrls;
    }

    await _client.from('posts').update(updates).eq('id', postId);
  }

  Future<void> deletePost(String postId) async {
    await _client.from('posts').delete().eq('id', postId);
  }

  Future<void> toggleLikePost(String postId, bool currentlyLiked) async {
    if (currentUser == null) return;
    if (currentlyLiked) {
      await _client
          .from('post_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', currentUser!.id);
    } else {
      await _client.from('post_likes').insert({
        'post_id': postId,
        'user_id': currentUser!.id,
      });
    }
  }

  // COMMENTS API
  Future<List<CommentModel>> fetchComments(String postId) async {
    try {
      final res = await _client.from('comments').select('''
        *,
        profiles!comments_author_id_fkey (display_name, avatar_url)
      ''').eq('post_id', postId).order('created_at', ascending: true);

      return (res as List).map((map) {
        final profile = map['profiles'] ?? {};
        return CommentModel(
          id: map['id'],
          postId: map['post_id'],
          authorId: map['author_id'],
          authorName: profile['display_name'] ?? 'Anonymous',
          authorAvatarUrl: profile['avatar_url'],
          content: map['content'],
          imageUrls: List<String>.from(map['image_urls'] ?? []),
          createdAt: DateTime.parse(map['created_at']),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<CommentModel?> createComment({
    required String postId,
    required String content,
    List<String> imageUrls = const [],
  }) async {
    if (currentUser == null) return null;

    final res = await _client.from('comments').insert({
      'post_id': postId,
      'author_id': currentUser!.id,
      'content': content,
      'image_urls': imageUrls,
    }).select('''
      *,
      profiles!comments_author_id_fkey (display_name, avatar_url)
    ''').single();

    final profile = res['profiles'] ?? {};

    return CommentModel(
      id: res['id'],
      postId: res['post_id'],
      authorId: res['author_id'],
      authorName: profile['display_name'] ?? 'Discourse User',
      authorAvatarUrl: profile['avatar_url'],
      content: res['content'],
      imageUrls: List<String>.from(res['image_urls'] ?? []),
      createdAt: DateTime.parse(res['created_at']),
    );
  }
}
