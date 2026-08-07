import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/comment_provider.dart';
import '../models/post_model.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 3) {
      context.push('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final commentProvider = Provider.of<CommentProvider>(context);
    final posts = postProvider.posts;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: const Color(0x0C000000),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF444748)),
          onPressed: () {},
        ),
        title: Text(
          'Discourse',
          style: GoogleFonts.libreCaslonText(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFE4E2E2),
                child: Icon(Icons.person, color: Color(0xFF444748), size: 20),
              ),
            ),
          ),
        ],
      ),
      body: posts.isEmpty && !postProvider.isLoading
          ? Center(
              child: Text(
                'No discussions yet. Create one!',
                style: GoogleFonts.hankenGrotesk(fontSize: 16, color: const Color(0xFF444748)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: posts.length + 1,
              itemBuilder: (context, index) {
                if (index == posts.length) {
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
                      : const SizedBox(height: 80);
                }

                final post = posts[index];
                final commentCount = commentProvider.getCommentCountForPost(post.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _buildPostCard(
                    context: context,
                    post: post,
                    commentCount: commentCount,
                    onLikeToggle: () => postProvider.toggleLike(post.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/post/create'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xCCFBF9F8),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF785A1A),
        unselectedItemColor: const Color(0xFF444748),
        selectedLabelStyle: GoogleFonts.hankenGrotesk(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.hankenGrotesk(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required BuildContext context,
    required PostModel post,
    required int commentCount,
    required VoidCallback onLikeToggle,
  }) {
    return GestureDetector(
      onTap: () => context.push('/post/${post.id}'),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Multi-Image Preview Carousel / Grid
            if (post.imageUrls.isNotEmpty)
              Container(
                height: 192,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.imageUrls.length,
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.imageUrls[idx],
                          width: 240,
                          height: 192,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 192,
                            color: const Color(0xFFE9E8E7),
                            child: const Icon(Icons.image, size: 48, color: Color(0xFFC4C7C7)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 192,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E8E7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 48, color: Color(0xFFC4C7C7)),
                ),
              ),
            const SizedBox(height: 12),
            // Tags
            if (post.tags.isNotEmpty)
              Row(
                children: post.tags.map((tag) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag.startsWith('#') ? tag : '#$tag',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF775A19),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: GoogleFonts.libreCaslonText(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                letterSpacing: -0.32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 16,
                color: const Color(0xFF444748),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0x7FE4E2E2)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFFE9E8E7),
                      backgroundImage: post.authorAvatarUrl != null && post.authorAvatarUrl!.isNotEmpty
                          ? NetworkImage(post.authorAvatarUrl!)
                          : null,
                      child: post.authorAvatarUrl == null || post.authorAvatarUrl!.isEmpty
                          ? const Icon(Icons.person, size: 16, color: Color(0xFF444748))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.authorName,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLikeToggle,
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: post.isLiked ? const Color(0xFFBA1A1A) : const Color(0xFF444748),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likesCount}',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF444748),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF444748)),
                        const SizedBox(width: 4),
                        Text(
                          '$commentCount',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF444748),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
