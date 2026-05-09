import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadHabitImage({
    required String userId,
    required String habitId,
    required File imageFile,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('uploads/$userId/$habitId/$fileName');
      
      // Upload file
      await ref.putFile(imageFile);
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Upload profile image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // 1. Validate file
      if (!await imageFile.exists()) throw 'File not found at path';
      if (await imageFile.length() == 0) throw 'File is empty';

      // 2. Simplify path
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');
      
      // 3. Upload with explicit metadata
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = ref.putFile(imageFile, metadata);
      
      // 4. Wait for completion
      final snapshot = await uploadTask;
      
      // 5. Small delay to allow for backend propagation
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 6. Get URL from the snapshot ref
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (e is FirebaseException) {
        throw 'Storage Error [${e.code}]: ${e.message}';
      }
      throw 'Upload Error: $e';
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteHabitImage({
    required String userId,
    required String habitId,
    required String imageUrl,
  }) async {
    try {
      // Extract the path from the download URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete image: $e';
    }
  }

  /// Get upload progress stream
  Future<void> uploadHabitImageWithProgress({
    required String userId,
    required String habitId,
    required File imageFile,
    required Function(double) onProgress,
    required Function(String) onComplete,
    required Function(String) onError,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('uploads/$userId/$habitId/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
      
      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      onComplete(downloadUrl);
    } catch (e) {
      onError('Failed to upload image: $e');
    }
  }
}
