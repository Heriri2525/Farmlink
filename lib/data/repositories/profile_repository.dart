import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmlink/data/repositories/auth_repository.dart';
import 'package:farmlink/data/models/profile_model.dart'; // Import Profile model

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> createProfile({
    required String userId,
    required String name,
    String? phone,
  }) async {
    await _supabase.from('profiles').insert({
      'id': userId,
      'name': name,
      'phone': phone,
    });
  }

  // Modified updateProfile to accept a Profile object
  Future<void> updateProfile(Profile profile) async {
    await _supabase.from('profiles').update(profile.toJson()).eq('id', profile.userId);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

// New provider for current user's profile
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final userId = ref.watch(authRepositoryProvider).currentUser;
  if (userId == null) {
    return null;
  }
  return ref.watch(profileRepositoryProvider).getProfile(userId);
});