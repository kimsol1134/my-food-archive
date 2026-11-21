import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:my_food_archive/models/archive_item.dart';
import 'package:my_food_archive/services/local_db_service.dart';
import 'package:my_food_archive/utils/app_paths.dart';

class _TestPathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _TestPathProvider(this.path);
  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

/// Real Hive files in a disposable directory; no user records or Firebase.
class ArchiveTestEnvironment {
  late Directory directory;
  late LocalDBService db;
  late PathProviderPlatform _originalPaths;

  Future<void> open() async {
    directory = await Directory.systemTemp.createTemp('archive_regression_');
    _originalPaths = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _TestPathProvider(directory.path);
    await AppPaths.init();
    await reopen();
  }

  Future<void> reopen() async {
    await Hive.close();
    db = LocalDBService();
    await db.initDB();
  }

  Future<void> clear() async {
    await Hive.box<ArchiveItem>('archiveItems').clear();
    final images = Directory('${directory.path}/images');
    if (await images.exists()) await images.delete(recursive: true);
    await images.create();
  }

  Future<void> close() async {
    await Hive.close();
    PathProviderPlatform.instance = _originalPaths;
    await directory.delete(recursive: true);
  }
}
