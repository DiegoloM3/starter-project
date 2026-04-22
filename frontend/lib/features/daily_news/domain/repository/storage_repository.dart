import 'dart:io';

abstract class StorageRepository {
  Future<String> uploadImage(File image, String userId);
}
