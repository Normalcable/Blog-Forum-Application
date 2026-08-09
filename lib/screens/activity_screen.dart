import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/comment_model.dart';
import '../providers/auth_provider.dart';
import '../providers/comment_provider.dart';
import '../providers/post_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final commentProvider = Provider.of<CommentProvider>(context);
    final currentUser = authProvider.currentUser;

    // 1. Posts published by current user
    final userPosts = postProvider.posts.where((p) => p.authorId == currentUser.id).toList();

    // 2. Comments & replies composed by current user
    final List<CommentModel> userComments = [];
    for (final post in postProvider.posts) {
      final comments = commentProvider.getCommentsForPost(post.id);
      for (final comment in comments) {
        if (comment.authorId == currentUser.id) {
          userComments.add(comment);
        }
      }
    }

    // 3. Posts liked by current user
    final likedPosts = postProvider.posts.where((p) => p.isLikedForUser(currentUser.id)).toList();

    ImageProvider? userAvatar;
    if (currentUser.avatarUrl != null && currentUser.avatarUrl!.isNotEmpty) {
      final url = currentUser.avatarUrl!;
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE4E2E2),
                backgroundImage: userAvatar,
                child: userAvatar == null
                    ? const Icon(Icons.person, color: Color(0xFF444748), size: 20)
                    : null,
              ),
            ),
          ),
        ),
        title: Text(
          'Discourse',
          style: GoogleFonts.libreCaslonText(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF444748)),
              onPressed: () => context.push('/search'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          // Section Title
          Text(
            'Activity History',
            style: GoogleFonts.libreCaslonText(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 1: YOUR POSTS
          _buildSectionHeader('YOUR POSTS'),
          const SizedBox(height: 12),
          if (userPosts.isEmpty)
            _buildEmptyActivityItem('You haven\'t published any discussions yet.')
          else
            ...userPosts.map((post) => Column(
                  children: [
                    InkWell(
                      onTap: () => context.push('/post/${post.id}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                        const TextSpan(
                                          text: 'You ',
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        const TextSpan(text: 'published '),
                                        TextSpan(
                                          text: '"${post.title}"',
                                          style: const TextStyle(fontStyle: FontStyle.italic),
                                        ),
                                        const TextSpan(text: '.'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '1d ago',
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 12,
                                      color: const Color(0xFF444748),
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
                )),

          const SizedBox(height: 32),

          // SECTION 2: YOUR COMMENTS & REPLIES
          _buildSectionHeader('YOUR COMMENTS & REPLIES'),
          const SizedBox(height: 12),
          if (userComments.isEmpty)
            _buildEmptyActivityItem('You haven\'t written any comments or replies yet.')
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
                                      const TextSpan(
                                        text: 'You ',
                                        style: TextStyle(fontWeight: FontWeight.w700),
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
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE4E2E2)),
                                  ),
                                  child: Text(
                                    '"${comment.content}"',
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFF444748),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Recently',
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 12,
                                    color: const Color(0xFF444748),
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

          const SizedBox(height: 32),

          // SECTION 3: LIKED POSTS
          _buildSectionHeader('LIKED POSTS'),
          const SizedBox(height: 12),
          if (likedPosts.isEmpty)
            _buildEmptyActivityItem('You haven\'t liked any posts yet.')
          else
            ...likedPosts.map((post) => Column(
                  children: [
                    InkWell(
                      onTap: () => context.push('/post/${post.id}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFFE9E8E7),
                              child: const Icon(Icons.person, size: 20, color: Color(0xFF444748)),
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
                                        const TextSpan(
                                          text: 'You ',
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        const TextSpan(text: 'liked '),
                                        TextSpan(
                                          text: '${post.authorName}\'s',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        const TextSpan(text: ' post '),
                                        TextSpan(
                                          text: '"${post.title}"',
                                          style: const TextStyle(fontStyle: FontStyle.italic),
                                        ),
                                        const TextSpan(text: '.'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Recently',
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 12,
                                      color: const Color(0xFF444748),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.favorite, size: 18, color: Color(0xFFBA1A1A)),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE5E2E1)),
                  ],
                )),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.hankenGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: const Color(0xFF444748),
      ),
    );
  }

  Widget _buildEmptyActivityItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        text,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          color: const Color(0xFF444748),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
