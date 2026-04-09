import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/archive_item.dart';

class ArchiveGridCard extends StatelessWidget {
  final ArchiveItem item;
  final VoidCallback? onTap;

  const ArchiveGridCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(item.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.photo,
                    size: 32,
                    color: AppColors.textSub,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.restaurantName,
          style: AppTextStyles.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          item.location,
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      ),
    );
  }
}
