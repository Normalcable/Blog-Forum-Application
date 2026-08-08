import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/supabase_config.dart';
import '../models/post_model.dart';
import '../services/supabase_service.dart';

class PostProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 10;

  List<PostModel> _posts = SupabaseConfig.isConfigured
      ? []
      : [
          PostModel(
            id: '1',
            authorId: 'user_2',
            authorName: 'Sarah Jenkins',
            authorHandle: '@sjenkins',
            title: 'The Architecture of Silence: Designing for Focus',
            content: "In an era defined by constant notification pings and algorithmic urgency, creating digital spaces that foster deep focus has become a radical act. We often talk about 'user engagement,' but rarely do we discuss 'user tranquility.'\n\nConsider the physical library. The architecture itself enforces a behavioral shift. High ceilings dampen sound, specific lighting arrangements delineate reading zones from stacks, and the overall volume of space demands a physical quietness. Can we replicate this in our interfaces?\n\nBy leveraging generous whitespace (what I prefer to call 'breathing room') and heavily restricting our color palettes, we can guide the user's eye without shouting at them. It's about designing islands of information rather than a sea of data.",
            community: 'design',
            tags: ['DesignTheory', 'UX', 'Minimalism'],
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            likesCount: 42,
          ),
          PostModel(
            id: '2',
            authorId: 'user_3',
            authorName: 'Elena Rostova',
            authorHandle: '@elena_design',
            title: 'The Art of Subtraction in UI Design',
            content: 'In a world cluttered with information, designing interfaces that prioritize clarity and focus is more critical than ever. We explore how removing elements can actually enhance the user experience.',
            community: 'design',
            tags: ['Design', 'Minimalism'],
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            likesCount: 18,
          ),
          PostModel(
            id: '3',
            authorId: 'user_1',
            authorName: 'Alexander Wright',
            authorHandle: '@alex_wright',
            title: 'Building Scalable State Systems in Flutter',
            content: 'State management is at the core of dynamic cross-platform applications. Using clean Architecture principles alongside Provider allows for predictable, maintainable application state flow.',
            community: 'tech',
            tags: ['Flutter', 'Architecture', 'StateManagement'],
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            likesCount: 29,
          ),
        ];

  List<PostModel> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  PostProvider() {
    fetchPosts();
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    if (!SupabaseConfig.isConfigured) return;

    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
    }

    _isLoading = true;
    notifyListeners();

    final fetched = await _supabaseService.fetchPosts(
      offset: _currentPage * _pageSize,
      limit: _pageSize,
    );

    if (fetched.length < _pageSize) {
      _hasMore = false;
    }

    if (refresh) {
      _posts = fetched;
    } else {
      _posts.addAll(fetched);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMorePosts() async {
    if (_isLoading || !_hasMore) return;
    _currentPage++;
    await fetchPosts(refresh: false);
  }

  PostModel? getPostById(String id) {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addPost({
    required String title,
    required String content,
    required String community,
    required List<String> tags,
    List<XFile> imageFiles = const [],
    required String authorName,
    required String authorHandle,
    required String authorId,
  }) async {
    List<String> imageUrls = [];

    if (imageFiles.isNotEmpty) {
      if (SupabaseConfig.isConfigured) {
        try {
          imageUrls = await _supabaseService.uploadImages(imageFiles, 'posts').timeout(const Duration(seconds: 15));
        } catch (e) {
          debugPrint('Supabase image upload failed/timed out, using local image paths: $e');
          imageUrls = imageFiles.map((f) => f.path).toList();
        }
      } else {
        imageUrls = imageFiles.map((f) => f.path).toList();
      }
    }

    if (SupabaseConfig.isConfigured) {
      try {
        final newPost = await _supabaseService.createPost(
          title: title,
          content: content,
          community: community,
          tags: tags,
          imageUrls: imageUrls,
        ).timeout(const Duration(seconds: 10));

        if (newPost != null) {
          _posts.insert(0, newPost);
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('Supabase post creation failed/timed out, adding post locally: $e');
      }
    }

    final localPost = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: authorId,
      authorName: authorName,
      authorHandle: authorHandle,
      title: title,
      content: content,
      community: community,
      tags: tags,
      imageUrls: imageUrls,
      createdAt: DateTime.now(),
      likesCount: 0,
    );

    _posts.insert(0, localPost);
    notifyListeners();
  }

  Future<void> updatePost({
    required String id,
    required String title,
    required String content,
    required String community,
    required List<String> tags,
    List<XFile> newImageFiles = const [],
    List<String>? existingImageUrls,
  }) async {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      List<String> finalUrls = List.from(existingImageUrls ?? _posts[index].imageUrls);

      if (newImageFiles.isNotEmpty) {
        if (SupabaseConfig.isConfigured) {
          try {
            final uploaded = await _supabaseService.uploadImages(newImageFiles, 'posts').timeout(const Duration(seconds: 15));
            finalUrls.addAll(uploaded);
          } catch (e) {
            debugPrint('Supabase image upload failed, keeping local paths: $e');
            finalUrls.addAll(newImageFiles.map((f) => f.path));
          }
        } else {
          finalUrls.addAll(newImageFiles.map((f) => f.path));
        }
      }

      _posts[index] = _posts[index].copyWith(
        title: title,
        content: content,
        community: community,
        tags: tags,
        imageUrls: finalUrls,
      );
      notifyListeners();

      if (SupabaseConfig.isConfigured) {
        try {
          await _supabaseService.updatePost(
            postId: id,
            title: title,
            content: content,
            community: community,
            tags: tags,
            imageUrls: finalUrls,
          ).timeout(const Duration(seconds: 10));
        } catch (e) {
          debugPrint('Supabase post update failed/timed out: $e');
        }
      }
    }
  }

  Future<void> deletePost(String id) async {
    _posts.removeWhere((p) => p.id == id);
    notifyListeners();

    if (SupabaseConfig.isConfigured) {
      await _supabaseService.deletePost(id);
    }
  }

  Future<void> toggleLike(String id) async {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final post = _posts[index];
      final wasLiked = post.isLiked;
      post.isLiked = !wasLiked;
      post.likesCount += post.isLiked ? 1 : -1;
      notifyListeners();

      if (SupabaseConfig.isConfigured) {
        await _supabaseService.toggleLikePost(id, wasLiked);
      }
    }
  }
}
