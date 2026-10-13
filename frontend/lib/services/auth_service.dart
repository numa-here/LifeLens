import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseService _supabaseService = SupabaseService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Sign in using Google OAuth
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_supabaseService.isMockMode) {
        // Mock fallback mode: simulate successful sign-in
        await Future.delayed(const Duration(milliseconds: 600));
        _currentUser = const UserProfile(
          id: 'demo-user-123',
          email: 'numa.dev@lifelens.ai',
          displayName: 'Numa (Demo)',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Live Supabase flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Failed to obtain Google ID Token.');
      }

      final response = await _supabaseService.client!.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user != null) {
        _currentUser = UserProfile(
          id: user.id,
          email: user.email ?? googleUser.email,
          displayName: user.userMetadata?['full_name'] ?? googleUser.displayName ?? 'LifeLens User',
          avatarUrl: user.userMetadata?['avatar_url'] ?? googleUser.photoUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AuthService] Google Sign-in error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// One-tap demo login for rapid frontend testing and hackathon judging
  Future<void> signInAsDemoUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = const UserProfile(
      id: 'demo-user-numa',
      email: 'numa.developer@lifelens.ai',
      displayName: 'Numa',
      avatarUrl: null,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!_supabaseService.isMockMode && _supabaseService.client != null) {
        await _supabaseService.client!.auth.signOut();
      }
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('[AuthService] Sign out error: $e');
    }

    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
