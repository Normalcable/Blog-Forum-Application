import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/supabase_config.dart';
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../providers/comment_provider.dart';
import '../providers/post_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  String _query = '';
  List<PostModel> _remoteResults = [];
  bool _isSearchingRemote = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    setState(() {
      _query = text;
    });

    if (SupabaseConfig.isConfigured && text.trim().isNotEmpty) {
      _performRemoteSearch(text.trim());
    }
  }

  Future<void> _performRemoteSearch(String q) async {
    setState(() {
      _isSearchingRemote = true;
    });

    final results = await _supabaseService.searchPosts(q);

    if (mounted && _query.trim() == q) {
      setState(() {
        _remoteResults = results;
        _isSearchingRemote = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final commentProvider = Provider.of<CommentProvider>(context);
    final currentUserId = authProvider.currentUser.id;

    // Combine local Provider filtering and remote Supabase results seamlessly
    final localResults = postProvider.searchPosts(_query);
    final combinedMap = <String, PostModel>{};

    for (final p in localResults) {
      combinedMap[p.id] = p;
    }
    for (final p in _remoteResults) {
      combinedMap[p.id] = p;
    }

    final searchResults = combinedMap.values.toList();
    final isQueryEmpty = _query.trim().isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: const Color(0x0C000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1C1C)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3F3),
            borderRadius: BorderRadius.circular(22),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search title, body, tags...',
              hintStyle: GoogleFonts.hankenGrotesk(
                color: const Color(0xFF775A19),
                fontSize: 15,
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF775A19), size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFF444748), size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: GoogleFonts.hankenGrotesk(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results Header / Loading Status
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isQueryEmpty
                      ? 'All Topics'
                      : 'Search Results (${searchResults.length})',
                  style: GoogleFonts.libreCaslonText(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (_isSearchingRemote)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF775A19)),
                  ),
              ],
            ),
          ),

          // Search Results List
          Expanded(
            child: isQueryEmpty
                ? _buildEmptyState(
                    icon: Icons.search,
                    title: 'Search Discourse',
                    subtitle: 'Type keywords above or tap a topic chip to filter discussions by title, body, or tags.',
                  )
                : searchResults.isEmpty && !_isSearchingRemote
                    ? _buildEmptyState(
                        icon: Icons.find_in_page_outlined,
                        title: 'No discussions found',
                        subtitle: 'We couldn\'t find any posts matching "$_query". Try searching for a different keyword or tag.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final post = searchResults[index];
                          final commentCount = commentProvider.getCommentCountForPost(post.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: PostCard(
                              post: post,
                              currentUserId: currentUserId,
                              commentCount: commentCount,
                              onLikeToggle: () => postProvider.toggleLike(post.id, currentUserId),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: -1),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F3F3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF775A19)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.libreCaslonText(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                color: const Color(0xFF444748),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
