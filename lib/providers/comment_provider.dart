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
              likesCount: 12,
            ),
            CommentModel(
              id: 'c2',
              postId: '1',
              authorId: 'user_3',
              authorName: 'Elena Rostova',
              content: "Exactly this! We need better metrics for 'quality of time spent' rather than just 'duration'.",
              createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
              likesCount: 3,
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
    List<XFile> imageFiles = const [],
  }) async {
    List<String> imageUrls = [];

    if (SupabaseConfig.isConfigured && imageFiles.isNotEmpty) {
      imageUrls = await _supabaseService.uploadImages(imageFiles, 'posts');
    }

    if (SupabaseConfig.isConfigured) {
      final newComment = await _supabaseService.createComment(
        postId: postId,
        content: content,
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
      content: content,
      imageUrls: imageUrls,
      createdAt: DateTime.now(),
      likesCount: 0,
    );

    if (!_commentsByPostId.containsKey(postId)) {
      _commentsByPostId[postId] = [];
    }
    _commentsByPostId[postId]!.add(localComment);
    notifyListeners();
  }

  void toggleLikeComment(String commentId) {
    for (var list in _commentsByPostId.values) {
      final index = list.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final comment = list[index];
        comment.isLiked = !comment.isLiked;
        comment.likesCount += comment.isLiked ? 1 : -1;
        notifyListeners();
        break;
      }
    }
  }
}
