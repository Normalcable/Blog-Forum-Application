import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/comment_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedIndex = 3;

  late TextEditingController _displayNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  XFile? _newAvatarFile;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      _displayNameController = TextEditingController(text: user.displayName);
      _usernameController = TextEditingController(text: user.username);
      _bioController = TextEditingController(text: user.bio);
      _initialized = true;
    }
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      if (index == 0) {
        context.push('/');
      }
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newAvatarFile = image;
      });
    }
  }

  void _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final commentProvider = Provider.of<CommentProvider>(context, listen: false);

      await auth.updateProfile(
        displayName: _displayNameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        newAvatarFile: _newAvatarFile,
      );

      final updatedUser = auth.currentUser;
      if (updatedUser.avatarUrl != null && updatedUser.avatarUrl!.isNotEmpty) {
        postProvider.updateUserAvatar(updatedUser.id, updatedUser.avatarUrl!);
        commentProvider.updateUserAvatar(updatedUser.id, updatedUser.avatarUrl!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _logout() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    ImageProvider? avatarImage;
    if (_newAvatarFile != null) {
      avatarImage = kIsWeb
          ? NetworkImage(_newAvatarFile!.path)
          : FileImage(File(_newAvatarFile!.path)) as ImageProvider;
    } else if (currentUser.avatarUrl != null && currentUser.avatarUrl!.isNotEmpty) {
      final url = currentUser.avatarUrl!;
      if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:') || url.startsWith('data:') || kIsWeb) {
        avatarImage = NetworkImage(url);
      } else {
        avatarImage = FileImage(File(url)) as ImageProvider;
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
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE4E2E2),
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? const Icon(Icons.person, color: Color(0xFF444748), size: 20)
                  : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        children: [
          // Profile Header & Avatar
          Column(
            children: [
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E8E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFBF9F8), width: 4),
                        image: avatarImage != null
                            ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                            : null,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            offset: Offset(0, 4),
                            blurRadius: 6,
                            spreadRadius: -1,
                          )
                        ],
                      ),
                      child: avatarImage == null
                          ? const Icon(Icons.person, size: 64, color: Color(0xFF444748))
                          : null,
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0x60000000),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.photo_camera, color: Colors.white, size: 32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Profile',
                style: GoogleFonts.libreCaslonText(
                  fontSize: 32,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your public persona and account settings.',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 16,
                  color: const Color(0xFF444748),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Form Area
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x33E4E2E2)),
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
                _buildLabel('Display Name'),
                const SizedBox(height: 8),
                _buildTextField(controller: _displayNameController),
                const SizedBox(height: 24),
                _buildLabel('Username (Handle)'),
                const SizedBox(height: 8),
                _buildTextField(controller: _usernameController, prefixText: '@'),
                const SizedBox(height: 24),
                _buildLabel('Short Bio'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _bioController,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Log Out Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 20),
              label: Text(
                'Log Out',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9E8E7),
                foregroundColor: const Color(0xFFBA1A1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF444748),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, String? prefixText, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.hankenGrotesk(
        fontSize: 16,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        prefixText: prefixText != null ? '$prefixText ' : null,
        prefixStyle: GoogleFonts.hankenGrotesk(fontSize: 16, color: const Color(0xFF444748)),
        filled: true,
        fillColor: const Color(0xFFF5F3F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
