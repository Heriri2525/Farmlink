import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/repositories/profile_repository.dart';

class AuthRepository {
  final SupabaseClient _supabase;
  final ProfileRepository _profileRepository;

  AuthRepository(this._supabase, this._profileRepository) {
    _supabase.auth.onAuthStateChange.listen((data) {
      final User? user = data.session?.user;
      if (user != null) {
        _ensureProfileExists(user);
      }
    });
  }

  // Get current user id
  String? get currentUser => _supabase.auth.currentUser?.id;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<void> _ensureProfileExists(User user, {String? name, String? phone}) async {
    final profile = await _profileRepository.getProfile(user.id);
    if (profile == null) {
      await _profileRepository.createProfile(
        userId: user.id,
        name: name ?? user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? user.email!.split('@').first,
        phone: phone ?? user.phone,
      );
    }
  }

  // Sign In with Email and Password
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      print('Auth Error: ${e.message}'); // DEBUG
      throw e.message;
    } catch (e) {
      print('Unexpected Error: $e'); // DEBUG
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign Up with Email and Password
  Future<void> signUp({required String email, required String password, required String name, required String phone}) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
        },
      );
      if (response.user == null) {
        throw 'Sign up failed';
      }
      // The onAuthStateChange listener will handle profile creation
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign In with Google (OAuth)
  Future<bool> signInWithGoogle() async {
    try {
      final redirectUrl = kIsWeb ? null : 'com.example.farmlink://login-callback/';
      
      final res = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        queryParams: {'prompt': 'select_account consent'},
        redirectTo: redirectUrl,
      );
      
      return res; 
    } catch (e) {
      throw e.toString();
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return AuthRepository(Supabase.instance.client, profileRepository);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
