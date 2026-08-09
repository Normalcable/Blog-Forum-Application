class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String? parentId;
  final String? parentAuthorName;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final Set<String> likedUserIds;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    this.parentId,
    this.parentAuthorName,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    Set<String>? likedUserIds,
  }) : likedUserIds = likedUserIds ?? {};

  int get likesCount => likedUserIds.length;

  bool isLikedForUser(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return likedUserIds.contains(userId);
  }

  CommentModel copyWith({
    String? authorName,
    String? authorAvatarUrl,
    String? parentId,
    String? parentAuthorName,
    String? content,
    List<String>? imageUrls,
    Set<String>? likedUserIds,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      authorId: authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      parentId: parentId ?? this.parentId,
      parentAuthorName: parentAuthorName ?? this.parentAuthorName,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt,
      likedUserIds: likedUserIds ?? Set.from(this.likedUserIds),
    );
  }
}
