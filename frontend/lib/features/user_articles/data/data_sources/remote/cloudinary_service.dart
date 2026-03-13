import 'dart:io';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/config/env_config.dart';

/// Service for uploading images to Cloudinary.
/// Uses unsigned uploads with upload presets for security.
abstract class CloudinaryService {
  /// Uploads an image file to Cloudinary.
  /// Returns the secure URL of the uploaded image.
  Future<String> uploadImage(File imageFile, {String? folder});
}

/// Implementation of CloudinaryService using Dio for HTTP requests.
class CloudinaryServiceImpl implements CloudinaryService {
  final Dio _dio;
  final String _cloudName;
  final String _uploadPreset;

  CloudinaryServiceImpl({
    String? cloudName,
    String? uploadPreset,
    Dio? dio,
  })  : _cloudName = cloudName ?? EnvConfig.cloudinaryCloudName,
        _uploadPreset = uploadPreset ?? EnvConfig.cloudinaryUploadPreset,
        _dio = dio ?? Dio();

  /// Creates a CloudinaryService with configuration from environment variables.
  factory CloudinaryServiceImpl.fromEnv({Dio? dio}) {
    return CloudinaryServiceImpl(
      cloudName: EnvConfig.cloudinaryCloudName,
      uploadPreset: EnvConfig.cloudinaryUploadPreset,
      dio: dio,
    );
  }

  /// Cloudinary upload URL for unsigned uploads.
  String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  @override
  Future<String> uploadImage(File imageFile, {String? folder}) async {
    try {
      // Debug logging
      print('[Cloudinary] Starting upload...');
      print('[Cloudinary] Cloud name: $_cloudName');
      print('[Cloudinary] Upload preset: $_uploadPreset');
      print('[Cloudinary] File path: ${imageFile.path}');
      print('[Cloudinary] URL: $_uploadUrl');

      // Validate configuration
      if (_cloudName.isEmpty) {
        throw Exception(
          'Cloudinary cloud name not configured. '
          'Set CLOUDINARY_CLOUD_NAME environment variable. '
          'See docs/ENV_CONFIG.md for setup instructions.',
        );
      }

      if (_uploadPreset.isEmpty) {
        throw Exception(
          'Cloudinary upload preset not configured. '
          'Set CLOUDINARY_UPLOAD_PRESET environment variable.',
        );
      }

      // Get the file name
      final fileName = imageFile.path.split('/').last;

      // Create form data for multipart upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'upload_preset': _uploadPreset,
        if (folder != null) 'folder': folder,
      });

      print('[Cloudinary] Sending request...');

      // Make the upload request
      final response = await _dio.post(
        _uploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('[Cloudinary] Response status: ${response.statusCode}');

      // Extract the secure URL from the response
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final secureUrl = data['secure_url'] as String?;

        if (secureUrl == null) {
          throw Exception('No secure_url in Cloudinary response');
        }

        print('[Cloudinary] Upload successful! URL: $secureUrl');
        return secureUrl;
      } else {
        final errorBody = response.data;
        print('[Cloudinary] Upload failed: $errorBody');
        throw Exception(
          'Cloudinary upload failed with status: ${response.statusCode}, '
          'body: $errorBody',
        );
      }
    } on DioError catch (e) {
      // Log the full error for debugging
      final responseData = e.response?.data;
      throw Exception(
        'Image upload failed: ${e.message}, '
        'status: ${e.response?.statusCode}, '
        'response: $responseData',
      );
    } catch (e) {
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }
}

/// Factory class for creating CloudinaryService instances.
/// Helps with dependency injection and configuration.
class CloudinaryServiceFactory {
  /// Creates a CloudinaryService from environment configuration.
  /// If cloudName and uploadPreset are not provided, uses EnvConfig values.
  ///
  /// Usage:
  /// ```dart
  /// // Using environment variables (recommended)
  /// final service = CloudinaryServiceFactory.create();
  ///
  /// // Or with explicit values
  /// final service = CloudinaryServiceFactory.create(
  ///   cloudName: 'your_cloud_name',
  ///   uploadPreset: 'your_upload_preset',
  /// );
  /// ```
  static CloudinaryService create({
    String? cloudName,
    String? uploadPreset,
  }) {
    return CloudinaryServiceImpl(
      cloudName: cloudName ?? EnvConfig.cloudinaryCloudName,
      uploadPreset: uploadPreset ?? EnvConfig.cloudinaryUploadPreset,
    );
  }

  /// Creates a CloudinaryService using only environment variables.
  static CloudinaryService fromEnv() {
    return CloudinaryServiceImpl.fromEnv();
  }
}
