import 'package:path_provider/path_provider.dart';

/// 앱 전용 문서 디렉토리의 절대 경로를 한 번만 조회해 캐싱하는 정적 헬퍼.
///
/// `ArchiveItem.imagePath`는 앱 전용 디렉토리 기준 *상대* 경로로 저장된다.
/// 앱 재설치/OS 업데이트 시 절대 경로의 앞부분(샌드박스 컨테이너 경로)이
/// 달라질 수 있으므로, 화면에서 `Image.file`로 사진을 그릴 때 [resolve]로
/// 상대 경로를 그 시점의 절대 경로로 변환한다. (iOS 원본과 100% 동일 — 플랫폼 무관)
///
/// main()에서 `runApp` 이전에 [init]을 반드시 호출해야 한다. 호출이 빠지면
/// [documentsDir] 접근 시 `LateInitializationError`로 크래시한다.
class AppPaths {
  AppPaths._();

  /// 앱 전용 문서 디렉토리의 절대 경로. [init] 호출 후에만 접근 가능.
  static late final String documentsDir;

  /// `getApplicationDocumentsDirectory()` 결과를 한 번만 캐싱한다.
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    documentsDir = dir.path;
  }

  /// 앱 전용 디렉토리 기준 상대 경로를 현재 절대 경로로 변환한다.
  static String resolve(String relativePath) => '$documentsDir/$relativePath';
}
