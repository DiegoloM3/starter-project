import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for secure local storage operations.
/// Uses flutter_secure_storage for encrypted key-value storage.
abstract class SecureStorageService {
  /// Reads a value from secure storage.
  Future<String?> read(String key);

  /// Writes a value to secure storage.
  Future<void> write(String key, String value);

  /// Deletes a value from secure storage.
  Future<void> delete(String key);

  /// Deletes all values from secure storage.
  Future<void> deleteAll();

  /// Checks if a key exists in secure storage.
  Future<bool> containsKey(String key);
}

/// Implementation of SecureStorageService using flutter_secure_storage.
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      // Log error and return null for graceful degradation
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      // Log error - storage write failed
      rethrow;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      // Log error - storage delete failed
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      // Log error - storage deleteAll failed
      rethrow;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      // Log error and return false for graceful degradation
      return false;
    }
  }
}
