import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/comment_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<PostProvider>(context, listen: false).fetchPosts(refresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final commentProvider = Provider.of<CommentProvider>(context);
    final posts = postProvider.posts;
    final user = authProvider.currentUser;

    ImageProvider? userAvatar;
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      final url = user.avatarUrl!;
      if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:') || url.startsWith('data:') || kIsWeb) {
        userAvatar = NetworkImage(url);
      } else {
        userAvatar = FileImage(File(url)) as ImageProvider;
      }
    }
    final firstName = user.displayName.split(' ').first;

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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: posts.isEmpty && !postProvider.isLoading ? 2 : posts.length + 2,
        itemBuilder: (context, index) {
          // Index 0: Top Facebook-style Create Post Bar
          if (index == 0) {
            return _buildCreatePostBar(context, userAvatar, firstName);
          }

          // If no posts yet
          if (posts.isEmpty && !postProvider.isLoading) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Text(
                  'No discussions yet. Spark the first one!',
                  style: GoogleFonts.hankenGrotesk(fontSize: 16, color: const Color(0xFF444748)),
                ),
              ),
            );
          }

          // Last Index: Load More / Bottom Spacing
          if (index == posts.length + 1) {
            return postProvider.hasMore
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: postProvider.isLoading ? null : () => postProvider.loadMorePosts(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Color(0x7FE4E2E2)),
                          backgroundColor: const Color(0xFFE9E8E7),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: postProvider.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : Text(
                                'Load More',
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  )
                : const SizedBox(height: 40);
          }

          final post = posts[index - 1];
          final commentCount = commentProvider.getCommentCountForPost(post.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: PostCard(
              post: post,
              currentUserId: authProvider.currentUser.id,
              commentCount: commentCount,
              onLikeToggle: () => postProvider.toggleLike(post.id, authProvider.currentUser.id),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildCreatePostBar(BuildContext context, ImageProvider? userAvatar, String firstName) {
    return GestureDetector(
      onTap: () => context.push('/post/create'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4E2E2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE4E2E2),
              backgroundImage: userAvatar,
              child: userAvatar == null
                  ? const Icon(Icons.person, color: Color(0xFF444748), size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Start a discussion, $firstName...',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 14,
                    color: const Color(0xFF747878),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.photo_library_outlined,
              color: Color(0xFF775A19),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
