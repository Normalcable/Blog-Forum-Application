class UserModel {
  final String id;
  String displayName;
  String username;
  String bio;
  String? avatarUrl;

  UserModel({
    required this.id,
    required this.displayName,
    required this.username,
    required this.bio,
    this.avatarUrl,
  });

  UserModel copyWith({
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
