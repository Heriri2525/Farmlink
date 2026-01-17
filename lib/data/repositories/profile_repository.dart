import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmlink/data/repositories/auth_repository.dart';
import 'package:farmlink/data/models/profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository(this._firestore);

  Future<Profile?> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('profiles').doc(userId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return Profile.fromJson(data);
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  Future<void> createProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String userType = 'buyer',
  }) async {
    try {
      await _firestore.collection('profiles').doc(userId).set({
        'user_id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'user_type': userType,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Error creating profile: $e';
    }
  }

  Future<void> updateProfile(Profile profile) async {
    try {
      await _firestore
          .collection('profiles')
          .doc(profile.userId)
          .set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw 'Error updating profile: $e';
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(FirebaseFirestore.instance);
});

final userProfileProvider = StreamProvider<Profile?>((ref) {
  final userId = ref.watch(authRepositoryProvider).currentUser;
  if (userId == null) {
    return Stream.value(null);
  }
  
  return FirebaseFirestore.instance
      .collection('profiles')
      .doc(userId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        final data = doc.data()!;
        data['id'] = doc.id;
        return Profile.fromJson(data);
      });
});