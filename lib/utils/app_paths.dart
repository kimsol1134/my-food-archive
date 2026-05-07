import 'package:path_provider/path_provider.dart';

class AppPaths {
  static late final String documentsDir;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    documentsDir = dir.path;
  }

  static String resolve(String relativePath) => '$documentsDir/$relativePath';
}
