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
import '../models/comment_model.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  final List<XFile> _commentImages = [];
  CommentModel? _replyingToComment;

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

  void _onReplyToComment(CommentModel comment) {
    setState(() {
      _replyingToComment = comment;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToComment = null;
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
                          GestureDetector(
                            onTap: () {
                              if (post.authorId == currentUser.id) {
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
                                      if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:') || url.startsWith('data:') || kIsWeb) {
                                        authorAvatar = NetworkImage(url);
                                      } else {
                                        authorAvatar = FileImage(File(url)) as ImageProvider;
                                      }
                                    }
                                    return CircleAvatar(
                                      radius: 20,
                                      backgroundColor: const Color(0xFFE9E8E7),
                                      backgroundImage: authorAvatar,
                                      child: authorAvatar == null
                                          ? const Icon(Icons.person, size: 24, color: Color(0xFF444748))
                                          : null,
                                    );
                                  },
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
                  ..._buildThreadedComments(comments, currentUser.id, commentProvider, post.id),
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
                  if (_replyingToComment != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3F3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE4E2E2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.reply, size: 16, color: Color(0xFF775A19)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Replying to @${_replyingToComment!.authorName}',
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF775A19),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: _cancelReply,
                            child: const Icon(Icons.close, size: 16, color: Color(0xFF444748)),
                          ),
                        ],
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
                            focusNode: _commentFocusNode,
                            maxLines: 4,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: _replyingToComment != null
                                  ? 'Write a reply to @${_replyingToComment!.authorName}...'
                                  : 'Add a response...',
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
                                authorAvatarUrl: currentUser.avatarUrl,
                                parentId: _replyingToComment?.id,
                                parentAuthorName: _replyingToComment?.authorName,
                                imageFiles: List.from(_commentImages),
                              );
                              _commentController.clear();
                              setState(() {
                                _commentImages.clear();
                                _replyingToComment = null;
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
    required CommentModel comment,
    required String author,
    String? avatarUrl,
    String? parentAuthorName,
    required String time,
    required String content,
    required List<String> imageUrls,
    required String likes,
    required bool isLiked,
    required bool isOwner,
    required VoidCallback onLikeToggle,
    required VoidCallback onDelete,
    required VoidCallback onReply,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            context.push('/user/${comment.authorId}');
          },
          child: Builder(
            builder: (context) {
              ImageProvider? commentAvatar;
              if (avatarUrl != null && avatarUrl.isNotEmpty) {
                if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://') || avatarUrl.startsWith('blob:') || avatarUrl.startsWith('data:') || kIsWeb) {
                  commentAvatar = NetworkImage(avatarUrl);
                } else {
                  commentAvatar = FileImage(File(avatarUrl)) as ImageProvider;
                }
              }
              return CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE9E8E7),
                backgroundImage: commentAvatar,
                child: commentAvatar == null
                    ? const Icon(Icons.person, size: 24, color: Color(0xFF444748))
                    : null,
              );
            },
          ),
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
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.push('/user/${comment.authorId}');
                            },
                            child: Text(
                              author,
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (parentAuthorName != null && parentAuthorName.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.play_arrow, size: 12, color: Color(0xFF775A19)),
                            const SizedBox(width: 4),
                            Text(
                              parentAuthorName,
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF775A19),
                              ),
                            ),
                          ],
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
                    GestureDetector(
                      onTap: onReply,
                      child: Row(
                        children: [
                          const Icon(Icons.reply, size: 18, color: Color(0xFF444748)),
                          const SizedBox(width: 4),
                          Text(
                            'Reply',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF444748),
                            ),
                          ),
                        ],
                      ),
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

  List<Widget> _buildThreadedComments(
    List<CommentModel> comments,
    String currentUserId,
    CommentProvider commentProvider,
    String postId,
  ) {
    final rootComments = comments.where((c) => c.parentId == null || c.parentId!.isEmpty).toList();

    final Map<String, List<CommentModel>> replyMap = {};
    for (final c in comments) {
      if (c.parentId != null && c.parentId!.isNotEmpty) {
        replyMap.putIfAbsent(c.parentId!, () => []).add(c);
      }
    }

    List<Widget> widgets = [];
    final Set<String> renderedCommentIds = {};

    void renderCommentAndChildren(CommentModel comment, double indentLevel) {
      if (renderedCommentIds.contains(comment.id)) return;
      renderedCommentIds.add(comment.id);

      final isOwner = comment.authorId == currentUserId;
      final isLiked = comment.isLikedForUser(currentUserId);
      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: indentLevel, bottom: 12.0),
          child: _buildComment(
            comment: comment,
            author: comment.authorName,
            avatarUrl: comment.authorAvatarUrl,
            parentAuthorName: comment.parentAuthorName,
            time: 'Just now',
            content: comment.content,
            imageUrls: comment.imageUrls,
            likes: '${comment.likesCount}',
            isLiked: isLiked,
            isOwner: isOwner,
            onLikeToggle: () => commentProvider.toggleLikeComment(comment.id, currentUserId),
            onDelete: () => commentProvider.deleteComment(postId, comment.id),
            onReply: () => _onReplyToComment(comment),
          ),
        ),
      );

      final children = replyMap[comment.id] ?? [];
      for (final child in children) {
        renderCommentAndChildren(child, (indentLevel + 24.0).clamp(0.0, 48.0));
      }
    }

    for (final root in rootComments) {
      renderCommentAndChildren(root, 0.0);
    }

    // Render any orphan replies (replies whose parent comment was deleted or not in list)
    for (final c in comments) {
      if (!renderedCommentIds.contains(c.id)) {
        renderCommentAndChildren(c, 24.0);
      }
    }

    return widgets;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }
}
