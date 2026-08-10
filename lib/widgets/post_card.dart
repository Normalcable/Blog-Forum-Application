import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/post_model.dart';

/// Shared Discussion Card Component used across FeedScreen, SearchScreen, and UserProfileScreen.
/// Displays post title, tags, content snippet, multi-image adaptive grid (1, 2, 3, 4+ layout), author header, and comment/like actions.
class PostCard extends StatelessWidget {
  final PostModel post;
  final String currentUserId;
  final int commentCount;
  final VoidCallback onLikeToggle;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.commentCount,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = post.isLikedForUser(currentUserId);
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
            // Title
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
            // Body Content Preview
            Text(
              post.content,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 16,
                height: 1.5,
                color: const Color(0xFF444748),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Adaptive Media Grid (Twitter/Facebook style)
            _buildAdaptiveMediaGrid(context, post.imageUrls),
            // Tags
            if (post.tags.isNotEmpty)
              Row(
                children: post.tags
                    .map((tag) => Padding(
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
                        ))
                    .toList(),
              ),
            const SizedBox(height: 24),
            const Divider(color: Color(0x7FE4E2E2)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (post.authorId == currentUserId) {
                      context.push('/profile');
                    } else {
                      context.push('/user/${post.authorId}');
                    }
                  },
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) {
                          ImageProvider? authorAvatar;
                          if (post.authorAvatarUrl != null && post.authorAvatarUrl!.isNotEmpty) {
                            final url = post.authorAvatarUrl!;
                            if (url.startsWith('http://') || url.startsWith('https://') || kIsWeb) {
                              authorAvatar = NetworkImage(url);
                            } else {
                              authorAvatar = FileImage(File(url)) as ImageProvider;
                            }
                          }
                          return CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFFE9E8E7),
                            backgroundImage: authorAvatar,
                            child: authorAvatar == null
                                ? const Icon(Icons.person, size: 16, color: Color(0xFF444748))
                                : null,
                          );
                        },
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
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLikeToggle,
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isLiked ? const Color(0xFFBA1A1A) : const Color(0xFF444748),
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

  Widget _buildAdaptiveMediaGrid(BuildContext context, List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    Widget buildSingleImage(String url, {double? width, double height = 200, Widget? overlay}) {
      final isNetworkOrWeb = kIsWeb ||
          url.startsWith('http://') ||
          url.startsWith('https://') ||
          url.startsWith('blob:') ||
          url.startsWith('data:');

      Widget imageWidget = isNetworkOrWeb
          ? Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: width,
                height: height,
                color: const Color(0xFFE9E8E7),
                child: const Icon(Icons.broken_image, size: 36, color: Color(0xFFC4C7C7)),
              ),
            )
          : Image.file(
              File(url),
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: width,
                height: height,
                color: const Color(0xFFE9E8E7),
                child: const Icon(Icons.broken_image, size: 36, color: Color(0xFFC4C7C7)),
              ),
            );

      if (overlay != null) {
        imageWidget = Stack(
          children: [
            Positioned.fill(child: imageWidget),
            Positioned.fill(child: overlay),
          ],
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageWidget,
      );
    }

    final count = imageUrls.length;

    if (count == 1) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        child: buildSingleImage(imageUrls[0], width: double.infinity, height: 220),
      );
    }

    if (count == 2) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 180,
        child: Row(
          children: [
            Expanded(child: buildSingleImage(imageUrls[0], height: 180)),
            const SizedBox(width: 4),
            Expanded(child: buildSingleImage(imageUrls[1], height: 180)),
          ],
        ),
      );
    }

    if (count == 3) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 200,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: buildSingleImage(imageUrls[0], height: 200),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: buildSingleImage(imageUrls[1], height: double.infinity)),
                  const SizedBox(height: 4),
                  Expanded(child: buildSingleImage(imageUrls[2], height: double.infinity)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 4 or more images (2x2 grid with +N badge for extra images)
    final remaining = count - 4;
    Widget? fourthOverlay;
    if (remaining > 0) {
      fourthOverlay = Container(
        color: Colors.black54,
        child: Center(
          child: Text(
            '+$remaining',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 220,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildSingleImage(imageUrls[0], height: double.infinity)),
                const SizedBox(width: 4),
                Expanded(child: buildSingleImage(imageUrls[1], height: double.infinity)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                Expanded(child: buildSingleImage(imageUrls[2], height: double.infinity)),
                const SizedBox(width: 4),
                Expanded(
                  child: buildSingleImage(
                    imageUrls[3],
                    height: double.infinity,
                    overlay: fourthOverlay,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
