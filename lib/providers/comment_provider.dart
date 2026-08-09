import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/supabase_config.dart';
import '../models/comment_model.dart';
import '../services/supabase_service.dart';

class CommentProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  final Map<String, List<CommentModel>> _commentsByPostId = SupabaseConfig.isConfigured
      ? {}
      : {
          '1': [
            CommentModel(
              id: 'c1',
              postId: '1',
              authorId: 'user_4',
              authorName: 'David Chen',
              content: "Brilliant take on the library analogy. I think the challenge is convincing stakeholders that 'quiet' interfaces don't mean 'dead' interfaces. Engagement metrics often punish subtlety.",
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            ),
            CommentModel(
              id: 'c2',
              postId: '1',
              authorId: 'user_3',
              authorName: 'Elena Rostova',
              content: "Exactly this! We need better metrics for 'quality of time spent' rather than just 'duration'.",
              createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
            ),
          ],
        };

  List<CommentModel> getCommentsForPost(String postId) {
    if (SupabaseConfig.isConfigured && !_commentsByPostId.containsKey(postId)) {
      fetchComments(postId);
    }
    return List.unmodifiable(_commentsByPostId[postId] ?? []);
  }

  int getCommentCountForPost(String postId) {
    return _commentsByPostId[postId]?.length ?? 0;
  }

  Future<void> fetchComments(String postId) async {
    if (!SupabaseConfig.isConfigured) return;

    final fetched = await _supabaseService.fetchComments(postId);
    _commentsByPostId[postId] = fetched;
    notifyListeners();
  }

  Future<void> addComment({
    required String postId,
    required String content,
    required String authorId,
    required String authorName,
    String? authorAvatarUrl,
    String? parentId,
    String? parentAuthorName,
    List<XFile> imageFiles = const [],
  }) async {
    List<String> imageUrls = [];

    if (imageFiles.isNotEmpty) {
      if (SupabaseConfig.isConfigured) {
        imageUrls = await _supabaseService.uploadImages(imageFiles, 'posts');
      } else {
        imageUrls = imageFiles.map((f) => f.path).toList();
      }
    }

    if (SupabaseConfig.isConfigured) {
      final newComment = await _supabaseService.createComment(
        postId: postId,
        content: content,
        parentId: parentId,
        parentAuthorName: parentAuthorName,
        imageUrls: imageUrls,
      );
      if (newComment != null) {
        if (!_commentsByPostId.containsKey(postId)) {
          _commentsByPostId[postId] = [];
        }
        _commentsByPostId[postId]!.add(newComment);
        notifyListeners();
        return;
      }
    }

    final localComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      parentId: parentId,
      parentAuthorName: parentAuthorName,
      content: content,
      imageUrls: imageUrls,
      createdAt: DateTime.now(),
    );

    if (!_commentsByPostId.containsKey(postId)) {
      _commentsByPostId[postId] = [];
    }
    _commentsByPostId[postId]!.add(localComment);
    notifyListeners();
  }

  void updateUserAvatar(String userId, String avatarUrl) {
    bool updated = false;
    for (var list in _commentsByPostId.values) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].authorId == userId) {
          list[i] = list[i].copyWith(authorAvatarUrl: avatarUrl);
          updated = true;
        }
      }
    }
    if (updated) {
      notifyListeners();
    }
  }

  void toggleLikeComment(String commentId, String currentUserId) {
    for (var list in _commentsByPostId.values) {
      final index = list.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final comment = list[index];
        final wasLiked = comment.likedUserIds.contains(currentUserId);
        final newLikedUserIds = Set<String>.from(comment.likedUserIds);
        if (wasLiked) {
          newLikedUserIds.remove(currentUserId);
        } else {
          newLikedUserIds.add(currentUserId);
        }
        list[index] = comment.copyWith(likedUserIds: newLikedUserIds);
        notifyListeners();
        break;
      }
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    if (_commentsByPostId.containsKey(postId)) {
      _commentsByPostId[postId]!.removeWhere((c) => c.id == commentId);
      notifyListeners();
    }

    if (SupabaseConfig.isConfigured) {
      await _supabaseService.deleteComment(commentId);
    }
  }
}
