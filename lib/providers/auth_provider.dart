import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel _currentUser = UserModel(
    id: 'user_1',
    displayName: 'Alexander Wright',
    username: 'alex_wright',
    bio: 'Digital philosopher exploring the intersection of technology and human connection. Avid reader, occasional writer.',
  );

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel get currentUser => _currentUser;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    if (SupabaseConfig.isConfigured && _supabaseService.isAuthenticated) {
      _isLoggedIn = true;
      _loadProfile(_supabaseService.currentUser!.id);
    }
  }

  Future<void> _loadProfile(String userId) async {
    final profile = await _supabaseService.getProfile(userId);
    if (profile != null) {
      _currentUser = profile;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (SupabaseConfig.isConfigured) {
        final res = await _supabaseService.signIn(email: email, password: password);
        if (res.user != null) {
          _isLoggedIn = true;
          await _loadProfile(res.user!.id);
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        _isLoggedIn = true;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (SupabaseConfig.isConfigured) {
        final res = await _supabaseService.signUp(email: email, password: password, displayName: name);
        if (res.user != null) {
          _isLoggedIn = true;
          await _loadProfile(res.user!.id);
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        _currentUser = _currentUser.copyWith(
          displayName: name.isNotEmpty ? name : 'Alexander Wright',
          username: name.toLowerCase().replaceAll(' ', '_'),
        );
        _isLoggedIn = true;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile({
    required String displayName,
    required String username,
    required String bio,
    XFile? newAvatarFile,
  }) async {
    String? newAvatarUrl;
    if (newAvatarFile != null) {
      if (SupabaseConfig.isConfigured) {
        newAvatarUrl = await _supabaseService.uploadAvatar(newAvatarFile);
      } else {
        newAvatarUrl = newAvatarFile.path;
      }
    }

    _currentUser = _currentUser.copyWith(
      displayName: displayName,
      username: username,
      bio: bio,
      avatarUrl: newAvatarUrl ?? _currentUser.avatarUrl,
    );
    notifyListeners();

    if (SupabaseConfig.isConfigured && _supabaseService.isAuthenticated) {
      try {
        await _supabaseService.updateProfile(
          userId: _currentUser.id,
          displayName: displayName,
          username: username,
          bio: bio,
          avatarUrl: newAvatarUrl,
        );
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    if (SupabaseConfig.isConfigured) {
      await _supabaseService.signOut();
    }
    _isLoggedIn = false;
    notifyListeners();
  }
}
