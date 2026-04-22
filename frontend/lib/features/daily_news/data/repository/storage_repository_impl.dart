import 'dart:io';
import 'dart:developer' as developer;
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/repository/storage_repository.dart';

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepositoryImpl(this._firebaseStorage);

  @override
  Future<String> uploadImage(File image, String userId) async {
    try {
      // Basic validation
      if (!await image.exists()) {
        throw Exception("El archivo seleccionado no existe en el sistema.");
      }
      
      final fileSize = await image.length();
      developer.log('Iniciando subida. Tamaño: ${fileSize / 1024} KB. Usuario: $userId', name: 'SymmetryStorage');

      final fileName = "art_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final path = 'users/$userId/articles/$fileName';
      final ref = _firebaseStorage.ref().child(path);
      
      developer.log('Destino en Storage: $path', name: 'SymmetryStorage');
      
      final uploadTask = await ref.putFile(
        image,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Monitor snapshot (optional but good for debugging)
      if (uploadTask.state == TaskState.error) {
        throw Exception("La tarea de subida falló inmediatamente.");
      }

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      developer.log('Subida completada. URL: $downloadUrl', name: 'SymmetryStorage');
      return downloadUrl;
    } catch (e) {
      developer.log('ERROR CRÍTICO STORAGE: $e', name: 'SymmetryStorage', error: e);
      
      if (e is FirebaseException) {
        developer.log('Código Firebase: ${e.code}', name: 'SymmetryStorage');
        developer.log('Mensaje Firebase: ${e.message}', name: 'SymmetryStorage');
        
        if (e.code == 'unauthorized') {
          throw Exception("Error de permisos: Revisa las reglas de seguridad de Firebase Storage.");
        } else if (e.code == 'canceled') {
          throw Exception("La subida fue cancelada.");
        }
      }
      
      throw Exception("Error al subir la imagen: ${e.toString()}");
    }
  }
}

