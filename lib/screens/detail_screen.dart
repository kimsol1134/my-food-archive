import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/archive_item.dart';
import '../providers/archive_provider.dart';
import '../utils/app_paths.dart';
import '../widgets/toast_message.dart';
import 'add_edit_record_screen.dart';

class DetailScreen extends StatelessWidget {
  final ArchiveItem item;

  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => AddEditRecordScreen(existingItem: item),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              CupertinoIcons.trash,
              color: AppColors.destructive,
            ),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailImage(imagePath: item.imagePath),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.restaurantName, style: AppTextStyles.title),
                  const SizedBox(height: 16),
                  _InfoRow(label: '메뉴', value: item.menuName),
                  const SizedBox(height: 8),
                  _InfoRow(label: '카테고리', value: item.category),
                  const SizedBox(height: 8),
                  _InfoRow(label: '지역', value: item.location),
                  const SizedBox(height: 8),
                  _InfoRow(label: '날짜', value: _formatDate(item.date)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('삭제'),
            onPressed: () async {
              final provider =
                  Provider.of<ArchiveProvider>(context, listen: false);
              final navigator = Navigator.of(context);
              final dialogNavigator = Navigator.of(dialogContext);
              await provider.deleteItem(item);
              if (!context.mounted) return;
              AppToast.show(context, '삭제되었습니다');
              dialogNavigator.pop();
              navigator.pop();
            },
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  return '${date.year}년 ${date.month}월 ${date.day}일';
}

class _DetailImage extends StatelessWidget {
  final String imagePath;

  const _DetailImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: Image.file(
        File(AppPaths.resolve(imagePath)),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: AppColors.surface,
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.photo,
              size: 64,
              color: AppColors.textSub,
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.textSub),
          ),
        ),
        Expanded(
          child: Text(value, style: AppTextStyles.body),
        ),
      ],
    );
  }
}
