import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/post_provider.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;

  const EditPostScreen({super.key, required this.postId});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late String _selectedCommunity;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  List<String> _existingImageUrls = [];
  final List<XFile> _newImageFiles = [];
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final post = postProvider.getPostById(widget.postId);

      _selectedCommunity = post?.community ?? 'general';
      _titleController = TextEditingController(text: post?.title ?? '');
      _contentController = TextEditingController(text: post?.content ?? '');
      _tagsController = TextEditingController(text: post?.tags.join(', ') ?? '');
      _existingImageUrls = List.from(post?.imageUrls ?? []);
      _initialized = true;
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _newImageFiles.addAll(images);
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
    });
  }

  void _saveChanges() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and content')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tagsText = _tagsController.text.trim();
      final tags = tagsText.isEmpty
          ? <String>[]
          : tagsText.split(',').map((t) => t.trim().replaceAll('#', '')).where((t) => t.isNotEmpty).toList();

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      await postProvider.updatePost(
        id: widget.postId,
        title: title,
        content: content,
        community: _selectedCommunity,
        tags: tags,
        existingImageUrls: _existingImageUrls,
        newImageFiles: _newImageFiles,
      );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update post: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: const Color(0x0C000000),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF444748)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Post',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Edit Discussion',
                    style: GoogleFonts.libreCaslonText(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
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
                      TextField(
                        controller: _titleController,
                        style: GoogleFonts.libreCaslonText(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'An interesting title...',
                          hintStyle: GoogleFonts.libreCaslonText(
                            fontSize: 24,
                            color: const Color(0xFFC4C7C7),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.numbers, size: 18, color: Color(0xFF775A19)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _tagsController,
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 14,
                                color: const Color(0xFF775A19),
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add tags (comma separated, e.g. Design, Flutter)',
                                hintStyle: GoogleFonts.hankenGrotesk(
                                  fontSize: 14,
                                  color: const Color(0xFFC4C7C7),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Color(0xFFF5F3F3)),
                      TextField(
                        controller: _contentController,
                        maxLines: 10,
                        minLines: 5,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Share your thoughts...',
                          hintStyle: GoogleFonts.hankenGrotesk(
                            fontSize: 18,
                            color: const Color(0xFFC4C7C7),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Media / Attachments Card
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
                              const Icon(Icons.image, color: Color(0xFF444748), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Attached Media (${_existingImageUrls.length + _newImageFiles.length})',
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF444748),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF775A19)),
                            onPressed: _pickImages,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFEDED),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFC4C7C7)),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, color: Color(0xFF444748)),
                                    SizedBox(height: 4),
                                    Text('Add Images', style: TextStyle(fontSize: 10, color: Color(0xFF444748))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Existing Cloud Images
                            ...List.generate(_existingImageUrls.length, (index) {
                              final url = _existingImageUrls[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: (url.startsWith('http') || url.startsWith('blob:') || kIsWeb)
                                              ? NetworkImage(url)
                                              : FileImage(File(url)) as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeExistingImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Color(0xCC000000),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Newly Selected Files
                            ...List.generate(_newImageFiles.length, (index) {
                              final file = _newImageFiles[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: kIsWeb
                                              ? NetworkImage(file.path)
                                              : FileImage(File(file.path)) as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeNewImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Color(0xCC000000),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xCCFFFFFF),
              border: Border(top: BorderSide(color: Color(0x4DE4E2E2))),
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Save Changes',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
