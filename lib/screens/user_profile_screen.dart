import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/supabase_config.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/comment_provider.dart';
import '../providers/post_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/post_card.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  UserModel? _profileUser;
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (SupabaseConfig.isConfigured) {
      setState(() => _isLoadingProfile = true);
      final profile = await _supabaseService.getProfile(widget.userId);
      if (mounted) {
        setState(() {
          _profileUser = profile;
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final commentProvider = Provider.of<CommentProvider>(context);
    final currentUserId = authProvider.currentUser.id;

    // Resolve target user model
    UserModel user;
    if (widget.userId == currentUserId) {
      user = authProvider.currentUser;
    } else if (_profileUser != null) {
      user = _profileUser!;
    } else {
      // Look for author info in existing posts
      final matchingPost = postProvider.posts.cast<dynamic>().firstWhere(
            (p) => p.authorId == widget.userId,
            orElse: () => null,
          );

      if (matchingPost != null) {
        user = UserModel(
          id: widget.userId,
          displayName: matchingPost.authorName,
          username: matchingPost.authorHandle.replaceAll('@', ''),
          avatarUrl: matchingPost.authorAvatarUrl,
          bio: 'Member of the Discourse community.',
        );
      } else {
        user = UserModel(
          id: widget.userId,
          displayName: 'Discourse User',
          username: 'user_${widget.userId.substring(0, widget.userId.length > 6 ? 6 : widget.userId.length)}',
          bio: 'Member of the Discourse community.',
        );
      }
    }

    // 1. Posts published by this target user
    final userPosts = postProvider.posts.where((p) => p.authorId == widget.userId).toList();

    // 2. Comments & replies composed by this target user
    final List<CommentModel> userComments = [];
    for (final post in postProvider.posts) {
      final comments = commentProvider.getCommentsForPost(post.id);
      for (final comment in comments) {
        if (comment.authorId == widget.userId) {
          userComments.add(comment);
        }
      }
    }

    // 3. Posts liked by this target user
    final likedPosts = postProvider.posts.where((p) => p.isLikedForUser(widget.userId)).toList();

    ImageProvider? userAvatar;
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      final url = user.avatarUrl!;
      if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:') || url.startsWith('data:') || kIsWeb) {
        userAvatar = NetworkImage(url);
      } else {
        userAvatar = FileImage(File(url)) as ImageProvider;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: const Color(0x0C000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1C1C)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.libreCaslonText(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                // User Profile Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E2E2)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        offset: Offset(0, 4),
                        blurRadius: 6,
                        spreadRadius: -1,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFE9E8E7),
                        backgroundImage: userAvatar,
                        child: userAvatar == null
                            ? const Icon(Icons.person, size: 44, color: Color(0xFF444748))
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName,
                        style: GoogleFonts.libreCaslonText(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF775A19),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (user.bio.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          user.bio,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            color: const Color(0xFF444748),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // SECTION 1: PUBLISHED POSTS
                _buildSectionHeader('${user.displayName.toUpperCase()}\'S POSTS (${userPosts.length})'),
                const SizedBox(height: 16),
                if (userPosts.isEmpty)
                  _buildEmptyState('No published posts yet.')
                else
                  ...userPosts.map((post) => Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: PostCard(
                          post: post,
                          currentUserId: currentUserId,
                          commentCount: commentProvider.getCommentCountForPost(post.id),
                          onLikeToggle: () => postProvider.toggleLike(post.id, currentUserId),
                        ),
                      )),

                const SizedBox(height: 24),

                // SECTION 2: COMMENTS & REPLIES
                _buildSectionHeader('${user.displayName.toUpperCase()}\'S COMMENTS (${userComments.length})'),
                const SizedBox(height: 16),
                if (userComments.isEmpty)
                  _buildEmptyState('No written comments yet.')
                else
                  ...userComments.map((comment) {
                    final post = postProvider.getPostById(comment.postId);
                    final postTitle = post?.title ?? 'discussion';
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => context.push('/post/${comment.postId}'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFE9E8E7),
                                  backgroundImage: userAvatar,
                                  child: userAvatar == null
                                      ? const Icon(Icons.person, size: 20, color: Color(0xFF444748))
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.hankenGrotesk(
                                            fontSize: 15,
                                            color: const Color(0xFF1B1C1C),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '${user.displayName} ',
                                              style: const TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                            TextSpan(
                                              text: comment.parentAuthorName != null
                                                  ? 'replied to ${comment.parentAuthorName} on '
                                                  : 'commented on ',
                                            ),
                                            TextSpan(
                                              text: '"$postTitle"',
                                              style: const TextStyle(fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFE4E2E2)),
                                        ),
                                        child: Text(
                                          comment.content,
                                          style: GoogleFonts.hankenGrotesk(
                                            fontSize: 14,
                                            color: const Color(0xFF444748),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E2E1)),
                      ],
                    );
                  }),

                const SizedBox(height: 24),

                // SECTION 3: LIKED POSTS
                _buildSectionHeader('LIKED POSTS (${likedPosts.length})'),
                const SizedBox(height: 16),
                if (likedPosts.isEmpty)
                  _buildEmptyState('No liked posts yet.')
                else
                  ...likedPosts.map((post) => Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: PostCard(
                          post: post,
                          currentUserId: currentUserId,
                          commentCount: commentProvider.getCommentCountForPost(post.id),
                          onLikeToggle: () => postProvider.toggleLike(post.id, currentUserId),
                        ),
                      )),

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.hankenGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: const Color(0xFF775A19),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          color: const Color(0xFF747878),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
