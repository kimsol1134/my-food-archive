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

/// 1.1 상세 보기 화면 — 개별 맛집 기록 확인 및 수정/삭제 진입
/// (IA.md §1.1, Design_guide.md §4.4).
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.item});

  final ArchiveItem item;

  /// 수정 아이콘 탭 — 기존 데이터를 들고 기록 수정 화면으로 이동.
  void _onEdit(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => AddEditRecordScreen(existingItem: item),
      ),
    );
  }

  /// 삭제 아이콘 탭 — iOS 스타일 확인 다이얼로그 노출(Design_guide.md §5).
  /// 실제 삭제(DB + 이미지 파일 + 홈 복귀)는 Task 13에서 구현한다.
  Future<void> _onDelete(BuildContext context) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('정말 삭제하시겠습니까?'),
        content: const Text('삭제한 기록은 복구할 수 없습니다.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<ArchiveProvider>();
    final navigator = Navigator.of(context);
    // pop 이후에도 토스트를 띄우려면 Overlay를 미리 확보해 둔다.
    final overlay = Overlay.of(context, rootOverlay: true);

    // DB 레코드 삭제 후 로컬 이미지 파일도 함께 정리한다.
    await provider.deleteItem(item.id);
    await _deleteImageFile(item.imagePath);

    navigator.pop();
    ToastMessage.showOnOverlay(overlay, '삭제되었습니다');
  }

  /// 로컬에 복사해 둔 이미지 파일을 삭제한다. 파일이 없거나 실패해도 무시한다.
  Future<void> _deleteImageFile(String relativePath) async {
    if (relativePath.isEmpty) return;
    try {
      final file = File(AppPaths.resolve(relativePath));
      if (await file.exists()) await file.delete();
    } catch (_) {
      // 파일 삭제 실패는 치명적이지 않으므로 무시(DB 레코드는 이미 삭제됨).
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxImageHeight = MediaQuery.of(context).size.height * 0.4;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: AppColors.textMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.pencil, color: AppColors.primary),
            onPressed: () => _onEdit(context),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: AppColors.destructive),
            onPressed: () => _onDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 원본 이미지 — 가로 꽉 차게, 높이는 화면의 40%로 제한.
            _DetailImage(imagePath: item.imagePath, maxHeight: maxImageHeight),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.restaurantName, style: AppTextStyles.title),
                  const SizedBox(height: 16),
                  if (item.menuName.isNotEmpty)
                    _MetaRow(label: '메뉴', value: item.menuName),
                  if (item.category.isNotEmpty)
                    _MetaRow(label: '카테고리', value: item.category),
                  if (item.location.isNotEmpty)
                    _MetaRow(label: '지역', value: item.location),
                  if (item.date != null)
                    _MetaRow(label: '날짜', value: _formatDate(item.date!)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 방문 일자를 "YYYY년 M월 D일" 한국어 표기로 변환한다(intl 의존 없이 단순 포맷).
String _formatDate(DateTime date) => '${date.year}년 ${date.month}월 ${date.day}일';

/// 상세 화면 상단 이미지. 로드 실패 시 회색 플레이스홀더로 대체한다.
class _DetailImage extends StatelessWidget {
  const _DetailImage({required this.imagePath, required this.maxHeight});

  final String imagePath;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: maxHeight,
      child: Image.file(
        File(AppPaths.resolve(imagePath)),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.surface,
          alignment: Alignment.center,
          child: const Icon(
            CupertinoIcons.photo,
            size: 48,
            color: AppColors.textSub,
          ),
        ),
      ),
    );
  }
}

/// 메타데이터 한 줄 — 좌측 고정폭 라벨(Caption) + 값(Body), 줄 간격 8px.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
