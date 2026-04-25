import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadArticleImage(File image) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('media/articles/$fileName');

      final uploadTask =
          await ref.putFile(image, SettableMetadata(contentType: 'image/jpeg'));

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error subiendo imagen: $e");
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception("Failed to delete image: $e");
    }
  }

  Future<String> uploadImageFromUrl(String url) async {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      final fileName = 'ai_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('media/articles/$fileName');

      final uploadTask = await ref.putData(
        Uint8List.fromList(response.data!),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error uploading image from URL: $e");
    }
  }
}
