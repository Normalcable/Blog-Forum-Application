class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  int likesCount;
  bool isLiked;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  CommentModel copyWith({
    String? authorName,
    String? authorAvatarUrl,
    String? content,
    List<String>? imageUrls,
    int? likesCount,
    bool? isLiked,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      authorId: authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
