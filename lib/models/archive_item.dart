import 'package:hive/hive.dart';

part 'archive_item.g.dart';

@HiveType(typeId: 0)
class ArchiveItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String restaurantName;

  @HiveField(3)
  final String menuName;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final DateTime? date;

  @HiveField(7)
  final String searchKeyword;

  ArchiveItem({
    required this.id,
    required this.imagePath,
    required this.restaurantName,
    required this.menuName,
    required this.category,
    required this.location,
    this.date,
    required this.searchKeyword,
  });

  static String generateSearchKeyword({
    required String restaurantName,
    required String menuName,
    required String category,
    required String location,
  }) {
    return '${restaurantName.replaceAll(' ', '')}'
        '${menuName.replaceAll(' ', '')}'
        '${category.replaceAll(' ', '')}'
        '${location.replaceAll(' ', '')}';
  }
}
