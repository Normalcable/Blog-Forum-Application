import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/post_detail_screen.dart';
import '../screens/create_post_screen.dart';
import '../screens/edit_post_screen.dart';
import '../screens/profile_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isLoggedIn ? '/' : '/login',
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final isLoggedIn = authProvider.isLoggedIn;
        
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToRegister = state.matchedLocation == '/register';
        
        if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
          final isGoingToFeed = state.matchedLocation == '/';
          final isGoingToPostDetail = state.matchedLocation.startsWith('/post/') &&
              !state.matchedLocation.contains('/edit') &&
              !state.matchedLocation.contains('/create');
          
          if (!isGoingToFeed && !isGoingToPostDetail) {
            return '/login';
          }
        }
        
        if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
          return '/';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const FeedScreen(),
        ),
        GoRoute(
          path: '/post/create',
          builder: (context, state) => const CreatePostScreen(),
        ),
        GoRoute(
          path: '/post/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return PostDetailScreen(postId: id);
          },
        ),
        GoRoute(
          path: '/post/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return EditPostScreen(postId: id);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }
}
