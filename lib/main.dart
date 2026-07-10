import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'providers/archive_provider.dart';
import 'screens/home_screen.dart';
import 'services/local_db_service.dart';
import 'utils/app_paths.dart';

Future<void> main() async {
  // 1. 플러그인/플랫폼 채널을 사용하기 전에 바인딩을 초기화한다.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Android 13+ Photo Picker를 명시적으로 강제한다(Task 2).
  enforceAndroidPhotoPicker();

  // 3. 앱 전용 문서 디렉토리 경로를 캐싱한다(이미지 상대→절대 경로 변환용).
  //    이 호출이 빠지면 Image.file 렌더링 시 LateInitializationError로 크래시한다.
  await AppPaths.init();

  // 4. Firebase 초기화 + App Check 활성화. AI 자동 태깅(Task 11)에 필요하다.
  //    아직 Firebase가 구성되지 않았어도(google-services.json/플러그인 미적용)
  //    앱 전체가 멈추지 않도록 예외를 삼키고 계속 진행한다. 이 경우 AI 호출만
  //    실패(null)로 폴백되고 사진/EXIF/검색/저장 등 나머지는 정상 동작한다.
  await _initFirebase();

  // 5. Hive 초기화 + TypeAdapter 등록 + Box 열기.
  final dbService = LocalDBService();
  await dbService.initDB();

  // 6. DB 서비스를 주입하여 앱을 실행한다.
  runApp(MyApp(dbService: dbService));
}

/// Firebase Core + App Check를 초기화한다.
///
/// Android 단독 빌드는 `google-services.json`(+ Google Services Gradle 플러그인)을
/// 통해 기본 [FirebaseOptions]를 읽으므로 옵션 인자 없이 [Firebase.initializeApp]을
/// 호출한다. Firebase가 아직 구성되지 않았다면 여기서 예외가 나는데, AI 외 기능은
/// Firebase 없이도 동작하므로 예외를 로깅만 하고 통과시킨다.
///
/// App Check: 디버그 빌드는 debug 프로바이더(첫 실행 시 Logcat에 디버그 토큰 출력 →
/// Firebase 콘솔에 등록 필요), 릴리스 빌드는 Play Integrity를 사용한다.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
    );
  } catch (e) {
    debugPrint('[Firebase] 초기화 건너뜀 — AI 자동 태깅 비활성화로 계속 진행: $e');
  }
}

/// Android 13+ Photo Picker를 명시적으로 강제한다.
/// `image_picker_android` 2.7+는 기본적으로 Photo Picker(`ACTION_PICK_IMAGES`)를
/// 사용하지만, 향후 패키지 업데이트에도 안전하도록 명시적으로 켜 둔다.
/// (iOS 등 다른 플랫폼에서는 `instance`가 `ImagePickerAndroid`가 아니므로 무시됨)
void enforceAndroidPhotoPicker() {
  final picker = ImagePickerPlatform.instance;
  if (picker is ImagePickerAndroid) {
    picker.useAndroidPhotoPicker = true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.dbService});

  /// main()에서 초기화한 Hive DB 서비스. ArchiveProvider에 주입한다.
  final LocalDBService dbService;

  @override
  Widget build(BuildContext context) {
    // 앱 전역 상태 관리 계층. 생성 즉시 DB에서 기존 기록을 로드한다.
    return ChangeNotifierProvider<ArchiveProvider>(
      create: (_) => ArchiveProvider(dbService)..loadItems(),
      child: MaterialApp(
        title: '마이 맛집 아카이브',
        debugShowCheckedModeBanner: false,
        // 라이트 모드 전용(Design_guide.md §1) — 기기가 다크모드여도 무조건 라이트로 고정.
        // darkTheme도 동일한 라이트 테마로 채워 themeMode가 흔들려도 다크가 적용되지 않게 한다.
        theme: _buildLightTheme(),
        darkTheme: _buildLightTheme(),
        themeMode: ThemeMode.light,
        // 전역 스크롤: iOS식 바운스 적용 + Android 기본 글로우 제거(Design_guide.md §5).
        scrollBehavior: const _BouncingScrollBehavior(),
        // 시스템 글꼴 크기 확대를 최대 1.2배로 제한하여 레이아웃 붕괴를 방지한다.
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.2),
            ),
            child: child!,
          );
        },
        home: const HomeScreen(),
      ),
    );
  }
}

/// Design_guide.md §2 컬러 시스템을 적용한 라이트 테마.
/// 커스텀 폰트는 추가하지 않고 시스템 기본 폰트(Android: Roboto)를 사용한다.
ThemeData _buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.destructive,
    ),
    dividerColor: AppColors.divider,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionHandleColor: AppColors.primary,
    ),
    // Pure Native(애플 순정) 느낌의 평평한 AppBar — 그림자/틴트 제거.
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textMain,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: AppColors.background,
      centerTitle: false,
    ),
  );
}

/// 전역 스크롤 동작: iOS식 바운스를 적용하고 Android 기본 글로우/스트레치를 제거한다.
class _BouncingScrollBehavior extends MaterialScrollBehavior {
  const _BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Android 글로우(Stretch) 오버스크롤 인디케이터를 표시하지 않는다.
    return child;
  }
}
