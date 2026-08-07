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
      setState(() => _isSaving = false);
      context.pop();
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
                // Media Management Card
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
                          Text(
                            'Post Media (${_existingImageUrls.length + _newImageFiles.length})',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF444748),
                            ),
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
                                    Text('Add', style: TextStyle(fontSize: 10, color: Color(0xFF444748))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ...List.generate(_existingImageUrls.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _existingImageUrls[index],
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
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
                            ...List.generate(_newImageFiles.length, (index) {
                              final file = _newImageFiles[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image(
                                        image: kIsWeb
                                            ? NetworkImage(file.path)
                                            : FileImage(File(file.path)) as ImageProvider,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
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
                const SizedBox(height: 24),
                // Tags
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
                          const Icon(Icons.save, size: 20),
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
