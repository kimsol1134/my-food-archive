import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'firebase_options.dart';
import 'providers/archive_provider.dart';
import 'screens/home_screen.dart';
import 'services/local_db_service.dart';
import 'utils/app_paths.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppPaths.init();

  await _initFirebase();

  final dbService = LocalDBService();
  await dbService.initDB();

  runApp(MyApp(dbService: dbService));
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );
  } catch (error) {
    // Android Firebase 설정 파일이 아직 없더라도 로컬 아카이브 기능은
    // 정상 실행한다. 이 경우 Firebase 기반 AI 분석만 비활성화된다.
    debugPrint('[Firebase] 초기화를 건너뜁니다: $error');
  }
}

class MyApp extends StatelessWidget {
  final LocalDBService dbService;

  const MyApp({super.key, required this.dbService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArchiveProvider(dbService)..loadItems(),
      child: MaterialApp(
        title: '마이 맛집 아카이브',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: ThemeData.light().copyWith(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            surface: AppColors.surface,
            error: AppColors.destructive,
          ),
          dividerColor: AppColors.divider,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textMain,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.2),
            ),
            child: ScrollConfiguration(
              behavior: const _BouncingScrollBehavior(),
              child: child!,
            ),
          );
        },
        home: const HomeScreen(),
      ),
    );
  }
}

class _BouncingScrollBehavior extends ScrollBehavior {
  const _BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
