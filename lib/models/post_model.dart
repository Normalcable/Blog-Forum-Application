class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorHandle;
  final String? authorAvatarUrl;
  final String title;
  final String content;
  final String community;
  final List<String> tags;
  final List<String> imageUrls;
  final DateTime createdAt;
  int likesCount;
  bool isLiked;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorHandle,
    this.authorAvatarUrl,
    required this.title,
    required this.content,
    required this.community,
    required this.tags,
    this.imageUrls = const [],
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  PostModel copyWith({
    String? title,
    String? content,
    String? community,
    List<String>? tags,
    List<String>? imageUrls,
    int? likesCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorHandle: authorHandle,
      authorAvatarUrl: authorAvatarUrl,
      title: title ?? this.title,
      content: content ?? this.content,
      community: community ?? this.community,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
