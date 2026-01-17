import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageRepository {
  final SupabaseClient _supabase;

  StorageRepository(this._supabase);

  // Upload an image to a specific bucket
  Future<String> uploadImage({
    required String bucket,
    required File imageFile,
    required String path,
  }) async {
    try {
      // Upload the file
      await _supabase.storage.from(bucket).upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final String publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
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
  return StorageRepository(Supabase.instance.client);
});
