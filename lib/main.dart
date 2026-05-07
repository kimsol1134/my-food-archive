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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    appleProvider: kDebugMode
        ? AppleProvider.debug
        : AppleProvider.appAttestWithDeviceCheckFallback,
  );

  final dbService = LocalDBService();
  await dbService.initDB();

  runApp(MyApp(dbService: dbService));
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
          return ScrollConfiguration(
            behavior: const _BouncingScrollBehavior(),
            child: child!,
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
