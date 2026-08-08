import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String _selectedCommunity = 'general';
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final List<XFile> _selectedImageFiles = [];
  bool _isPublishing = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImageFiles.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImageFiles.removeAt(index);
    });
  }

  void _publishPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and content')),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final tagsText = _tagsController.text.trim();
      final tags = tagsText.isEmpty
          ? <String>[]
          : tagsText.split(',').map((t) => t.trim().replaceAll('#', '')).where((t) => t.isNotEmpty).toList();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final user = authProvider.currentUser;

      await postProvider.addPost(
        title: title,
        content: content,
        community: _selectedCommunity,
        tags: tags,
        imageFiles: _selectedImageFiles,
        authorName: user.displayName,
        authorHandle: '@${user.username}',
        authorId: user.id,
      );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publishing post failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
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
          'New Post',
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
                    'Create Discussion',
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
                      Container(
                        padding: const EdgeInsets.only(bottom: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFE9E8E7))),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.group_outlined, color: Color(0xFF747878)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCommunity,
                                  isDense: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF444748)),
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 14,
                                    color: const Color(0xFF444748),
                                  ),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() => _selectedCommunity = newValue);
                                    }
                                  },
                                  items: const [
                                    DropdownMenuItem(value: 'general', child: Text('Select Community...')),
                                    DropdownMenuItem(value: 'design', child: Text('Design Systems')),
                                    DropdownMenuItem(value: 'tech', child: Text('Tech & Architecture')),
                                    DropdownMenuItem(value: 'philosophy', child: Text('Philosophy')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contentController,
                        maxLines: 10,
                        minLines: 5,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Share your thoughts, spark a discussion...',
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
                                'Attached Media (${_selectedImageFiles.length})',
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
                            ...List.generate(_selectedImageFiles.length, (index) {
                              final file = _selectedImageFiles[index];
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
                                        onTap: () => _removeImage(index),
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
                const SizedBox(height: 24),
                // Formatting Toolbar & Tags
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.format_bold, color: Color(0xFF444748)),
                          const SizedBox(width: 16),
                          const Icon(Icons.format_italic, color: Color(0xFF444748)),
                          const SizedBox(width: 16),
                          const Icon(Icons.link, color: Color(0xFF444748)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.tag, size: 18, color: Color(0xFF747878)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _tagsController,
                              style: GoogleFonts.hankenGrotesk(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Tag1, Tag2...',
                                hintStyle: GoogleFonts.hankenGrotesk(fontSize: 12, color: const Color(0xFFC4C7C7)),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
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
                onPressed: _isPublishing ? null : _publishPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isPublishing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Publish',
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
