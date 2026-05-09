import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum PhotoPickStatus { success, cancelled, permissionDenied, error }

class PhotoPickResult {
  final PhotoPickStatus status;
  final String? imagePath;

  const PhotoPickResult({required this.status, this.imagePath});
}

class PhotoService {
  static const _allowedExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.heic',
    '.heif',
    '.webp',
  };

  final ImagePicker _picker = ImagePicker();

  Future<PhotoPickResult> pickAndPersistImage() async {
    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      if (code.contains('denied') || code.contains('access')) {
        return const PhotoPickResult(status: PhotoPickStatus.permissionDenied);
      }
      return const PhotoPickResult(status: PhotoPickStatus.error);
    } catch (_) {
      return const PhotoPickResult(status: PhotoPickStatus.error);
    }

    if (picked == null) {
      return const PhotoPickResult(status: PhotoPickStatus.cancelled);
    }

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${docsDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final ext = _resolveExtension(picked.path);
      final fileName = '${const Uuid().v4()}$ext';
      await File(picked.path).copy('${imagesDir.path}/$fileName');

      return PhotoPickResult(
        status: PhotoPickStatus.success,
        imagePath: 'images/$fileName',
      );
    } catch (_) {
      return const PhotoPickResult(status: PhotoPickStatus.error);
    }
  }

  String _resolveExtension(String sourcePath) {
    final dotIndex = sourcePath.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == sourcePath.length - 1) {
      return '.jpg';
    }
    final ext = sourcePath.substring(dotIndex).toLowerCase();
    return _allowedExtensions.contains(ext) ? ext : '.jpg';
  }
}
