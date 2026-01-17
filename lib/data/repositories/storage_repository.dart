import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageRepository {
  final FirebaseStorage _storage;

  StorageRepository(this._storage);

  // Upload an image to a specific folder
  Future<String> uploadImage({
    required String bucket,
    required File imageFile,
    required String path,
  }) async {
    try {
      final ref = _storage.ref().child(bucket).child(path);
      await ref.putFile(imageFile);
      final String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Upload Error: $e';
    }
  }

  // Convenience method for product images
  Future<String> uploadProductImage(File imageFile, String fileName) {
    return uploadImage(
      bucket: 'products',
      path: 'product_$fileName',
      imageFile: imageFile,
    );
  }

  // Convenience method for profile images
  Future<String> uploadProfileImage(File imageFile, String userId) {
    return uploadImage(
      bucket: 'profiles',
      path: 'avatar_$userId',
      imageFile: imageFile,
    );
  }
}

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(FirebaseStorage.instance);
});
