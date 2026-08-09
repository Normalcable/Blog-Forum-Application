import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/comment_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final List<XFile> _commentImages = [];

  Future<void> _pickCommentImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _commentImages.addAll(images);
      });
    }
  }

  void _removeCommentImage(int index) {
    setState(() {
      _commentImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final commentProvider = Provider.of<CommentProvider>(context);

    final post = postProvider.getPostById(widget.postId);
    final currentUser = authProvider.currentUser;

    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Post not found or has been deleted.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final comments = commentProvider.getCommentsForPost(post.id);
    final isAuthor = post.authorId == currentUser.id;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: const Color(0x0C000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF444748)),
          onPressed: () => context.pop(),
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Post Header & Metadata
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFFE9E8E7),
                                backgroundImage: post.authorAvatarUrl != null && post.authorAvatarUrl!.isNotEmpty
                                    ? NetworkImage(post.authorAvatarUrl!)
                                    : null,
                                child: post.authorAvatarUrl == null || post.authorAvatarUrl!.isEmpty
                                    ? const Icon(Icons.person, size: 24, color: Color(0xFF444748))
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.authorName,
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    post.authorHandle,
                                    style: GoogleFonts.hankenGrotesk(
                                      fontSize: 12,
                                      color: const Color(0xFF444748),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (isAuthor)
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF444748)),
                                  onPressed: () => context.push('/post/${post.id}/edit'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Color(0xFFBA1A1A)),
                                  onPressed: () {
                                    postProvider.deletePost(post.id);
                                    context.pop();
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        post.title,
                        style: GoogleFonts.libreCaslonText(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          letterSpacing: -0.32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post.content,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Multi-Image Viewer (Below text)
                      if (post.imageUrls.isNotEmpty)
                        Column(
                          children: post.imageUrls.map((url) {
                            final isNetworkOrWeb = kIsWeb ||
                                url.startsWith('http://') ||
                                url.startsWith('https://') ||
                                url.startsWith('blob:') ||
                                url.startsWith('data:');

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: isNetworkOrWeb
                                    ? Image.network(
                                        url,
                                        width: double.infinity,
                                        height: 250,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 200,
                                          color: const Color(0xFFE9E8E7),
                                          child: const Icon(Icons.broken_image, size: 64, color: Color(0xFFC4C7C7)),
                                        ),
                                      )
                                    : Image.file(
                                        File(url),
                                        width: double.infinity,
                                        height: 250,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 200,
                                          color: const Color(0xFFE9E8E7),
                                          child: const Icon(Icons.broken_image, size: 64, color: Color(0xFFC4C7C7)),
                                        ),
                                      ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 32),
                      if (post.tags.isNotEmpty)
                        Row(
                          children: post.tags.map((tag) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3F3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag.startsWith('#') ? tag : '#$tag',
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1B1C19),
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Responses (${comments.length})',
                  style: GoogleFonts.libreCaslonText(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                if (comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'No responses yet. Be the first to share your thoughts!',
                      style: GoogleFonts.hankenGrotesk(fontSize: 14, color: const Color(0xFF444748)),
                    ),
                  )
                else
                  ...comments.map((comment) {
                    final isCommentAuthor = comment.authorId == currentUser.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildComment(
                        author: comment.authorName,
                        avatarUrl: comment.authorAvatarUrl,
                        time: 'Just now',
                        content: comment.content,
                        imageUrls: comment.imageUrls,
                        likes: '${comment.likesCount}',
                        isLiked: comment.isLiked,
                        isOwner: isCommentAuthor,
                        onLikeToggle: () => commentProvider.toggleLikeComment(comment.id),
                        onDelete: () => commentProvider.deleteComment(post.id, comment.id),
                      ),
                    );
                  }),
              ],
            ),
          ),
          
          // Sticky Comment Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xCCFBF9F8),
              border: Border(
                top: BorderSide(color: Color(0x4DE4E2E2)),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_commentImages.isNotEmpty)
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _commentImages.length,
                        itemBuilder: (context, idx) {
                          final file = _commentImages[idx];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image(
                                    image: kIsWeb
                                        ? NetworkImage(file.path)
                                        : FileImage(File(file.path)) as ImageProvider,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => _removeCommentImage(idx),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xCC000000),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x7FE4E2E2)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          offset: Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: -1,
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image, color: Color(0xFF444748)),
                          onPressed: _pickCommentImages,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            maxLines: 4,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Add a response...',
                              hintStyle: GoogleFonts.hankenGrotesk(
                                color: const Color(0xFF444748),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final text = _commentController.text.trim();
                            if (text.isNotEmpty || _commentImages.isNotEmpty) {
                              commentProvider.addComment(
                                postId: post.id,
                                content: text,
                                authorId: currentUser.id,
                                authorName: currentUser.displayName,
                                imageFiles: List.from(_commentImages),
                              );
                              _commentController.clear();
                              setState(() {
                                _commentImages.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Post',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildComment({
    required String author,
    String? avatarUrl,
    required String time,
    required String content,
    required List<String> imageUrls,
    required String likes,
    required bool isLiked,
    required bool isOwner,
    required VoidCallback onLikeToggle,
    required VoidCallback onDelete,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFE9E8E7),
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? const Icon(Icons.person, size: 24, color: Color(0xFF444748))
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4DE4E2E2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          author,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 12,
                            color: const Color(0xFF444748),
                          ),
                        ),
                      ],
                    ),
                    if (isOwner)
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)),
                      ),
                  ],
                ),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
                if (imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: imageUrls.map((url) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: url.startsWith('http://') || url.startsWith('https://') || kIsWeb
                          ? Image.network(
                              url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(url),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 12),
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
                            likes,
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              color: const Color(0xFF444748),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(Icons.reply, size: 18, color: Color(0xFF444748)),
                        const SizedBox(width: 4),
                        Text(
                          'Reply',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 14,
                            color: const Color(0xFF444748),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
