import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/repositories/profile_repository.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final ProfileRepository _profileRepository;

  AuthRepository(this._auth, this._profileRepository) {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _ensureProfileExists(user);
      }
    });
  }

  // Get current user id
  String? get currentUser => _auth.currentUser?.uid;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _ensureProfileExists(User user, {String? name, String? phone}) async {
    final profile = await _profileRepository.getProfile(user.uid);
    if (profile == null) {
      await _profileRepository.createProfile(
        userId: user.uid,
        name: name ?? user.displayName ?? user.email!.split('@').first,
        email: user.email!,
        phone: phone ?? user.phoneNumber,
      );
    }
  }

  // Sign In with Email and Password
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print('Auth Error: ${e.message}'); // DEBUG
      throw e.message ?? 'Authentication failed';
    } catch (e) {
      print('Unexpected Error: $e'); // DEBUG
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign Up with Email and Password
  Future<void> signUp({required String email, required String password, required String name, required String phone}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        // We ensure profile creation here as well to be sure
        await _ensureProfileExists(credential.user!, name: name, phone: phone);
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Sign up failed';
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign In with Google (OAuth)
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user != null;
    } catch (e) {
      throw e.toString();
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return AuthRepository(FirebaseAuth.instance, profileRepository);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
