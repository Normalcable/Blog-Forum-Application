/// Data model representing a Discussion or Blog Post.
/// Uses [Set<String>] for `likedUserIds` to ensure per-account like tracking isolation.
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

  /// Set of user IDs who have liked this post (prevents cross-account like bleed).
  final Set<String> likedUserIds;

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
    Set<String>? likedUserIds,
  }) : likedUserIds = likedUserIds ?? {};

  /// Total number of unique likes received by this post.
  int get likesCount => likedUserIds.length;

  /// Checks whether a specific logged-in user has liked this post.
  bool isLikedForUser(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return likedUserIds.contains(userId);
  }

  /// Creates a copy of [PostModel] with updated fields for immutable state transitions.
  PostModel copyWith({
    String? title,
    String? content,
    String? community,
    List<String>? tags,
    List<String>? imageUrls,
    String? authorAvatarUrl,
    Set<String>? likedUserIds,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorHandle: authorHandle,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      title: title ?? this.title,
      content: content ?? this.content,
      community: community ?? this.community,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt,
      likedUserIds: likedUserIds ?? Set.from(this.likedUserIds),
    );
  }
}
