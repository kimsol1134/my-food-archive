import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../utils/app_paths.dart';

/// 사진 선택 결과 상태(IA.md §1.0 FAB 분기).
enum PhotoPickStatus { success, cancelled, permissionDenied, error }

/// [PhotoService.pickAndPersistImage]의 반환값.
class PhotoPickResult {
  const PhotoPickResult(this.status, {this.relativePath});

  final PhotoPickStatus status;

  /// 성공 시 앱 문서 디렉토리 기준 상대 경로(예: `images/<uuid>.jpg`).
  final String? relativePath;
}

/// Android Photo Picker로 사진을 선택하고 앱 전용 디렉토리에 영구 복사하는 서비스
/// (Implement_plan_android.md Task 10).
///
/// 갤러리 원본은 캐시/임시 경로라 사라질 수 있으므로, 선택 즉시 `images/` 아래로
/// UUID 파일명으로 복사하고 그 *상대* 경로만 [ArchiveItem]에 저장한다.
class PhotoService {
  PhotoService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  static const Uuid _uuid = Uuid();

  /// 허용 확장자. 그 외 포맷은 `.jpg`로 저장한다(Android 미디어 디코더가
  /// HEIC/HEIF 등을 가져올 때 JPEG로 변환해주므로 안전).
  static const Set<String> _allowedExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  /// 갤러리에서 사진을 선택해 앱 디렉토리로 복사한 뒤 상대 경로를 돌려준다.
  Future<PhotoPickResult> pickAndPersistImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null) {
        return const PhotoPickResult(PhotoPickStatus.cancelled);
      }

      var ext = _extensionOf(picked.path);
      if (!_allowedExtensions.contains(ext)) ext = '.jpg';

      final imagesDir = Directory(AppPaths.resolve('images'));
      if (!imagesDir.existsSync()) {
        imagesDir.createSync(recursive: true);
      }

      final fileName = '${_uuid.v4()}$ext';
      await File(picked.path).copy('${imagesDir.path}/$fileName');

      return PhotoPickResult(
        PhotoPickStatus.success,
        relativePath: 'images/$fileName',
      );
    } on PlatformException catch (e) {
      // Android 12 이하에서 READ_EXTERNAL_STORAGE 거부 시.
      final code = e.code.toLowerCase();
      if (code.contains('denied') || code.contains('access')) {
        return const PhotoPickResult(PhotoPickStatus.permissionDenied);
      }
      return const PhotoPickResult(PhotoPickStatus.error);
    } catch (_) {
      return const PhotoPickResult(PhotoPickStatus.error);
    }
  }

  /// 파일 경로에서 소문자 확장자(`.`포함)를 추출한다. 없으면 빈 문자열.
  /// (package:path 의존 없이 직접 처리)
  String _extensionOf(String filePath) {
    final dot = filePath.lastIndexOf('.');
    final slash = filePath.lastIndexOf(RegExp(r'[/\\]'));
    if (dot <= slash || dot == filePath.length - 1) return '';
    return filePath.substring(dot).toLowerCase();
  }
}
