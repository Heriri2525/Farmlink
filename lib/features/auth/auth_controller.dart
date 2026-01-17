import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farmlink/data/repositories/auth_repository.dart';

// Stream provider to listen to auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Auth Controller to handle logic and UI state loading
class AuthController extends Notifier<bool> {
  late final AuthRepository _authRepository;

  @override
  bool build() {
    _authRepository = ref.watch(authRepositoryProvider);
    return false; // Initial loading state
  }

  Future<void> signIn(String email, String password) async {
    state = true; // Set loading
    try {
      await _authRepository.signIn(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> signUp(String email, String password, String name, String phone) async {
    state = true;
    try {
      await _authRepository.signUp(email: email, password: password, name: name, phone: phone);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> signOut() async {
    state = true;
     try {
      await _authRepository.signOut();
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> signInWithGoogle() async {
    state = true;
    try {
       await _authRepository.signInWithGoogle();
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, bool>(() {
  return AuthController();
});