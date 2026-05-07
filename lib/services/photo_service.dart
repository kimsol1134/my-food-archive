import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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

  Future<String?> pickAndPersistImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null) return null;

      final docsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${docsDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final ext = _resolveExtension(picked.path);
      final fileName = '${const Uuid().v4()}$ext';
      await File(picked.path).copy('${imagesDir.path}/$fileName');

      return 'images/$fileName';
    } catch (_) {
      return null;
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
