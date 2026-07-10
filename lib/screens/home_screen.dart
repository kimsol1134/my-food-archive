import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/archive_item.dart';
import '../providers/archive_provider.dart';
import '../services/photo_service.dart';
import '../widgets/archive_grid_card.dart';
import '../widgets/toast_message.dart';
import 'add_edit_record_screen.dart';
import 'detail_screen.dart';

/// 1.0 홈 화면 — 저장된 맛집을 그리드로 보여주고 검색하는 메인 뷰
/// (IA.md §1.0, Design_guide.md §4.2).
///
/// 상단 Large Title + 검색바, 본문은 상태에 따라 Empty State / 그리드 /
/// 검색 결과 없음으로 분기한다. 우하단 FAB로 새 기록을 추가한다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PhotoService _photoService = PhotoService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// FAB 탭 — 사진을 먼저 선택한 뒤 기록 추가 화면(생성 모드)으로 이동한다.
  /// 취소 시 홈에 머무르고, 권한 거부/오류 시 토스트는 Task 16에서 붙인다.
  Future<void> _onAddPressed() async {
    // 검색창에 포커스가 남아 있으면 키보드를 먼저 내린다(복귀 시 키보드 잔존 방지).
    FocusScope.of(context).unfocus();
    final result = await _photoService.pickAndPersistImage();
    if (!mounted) return;

    switch (result.status) {
      case PhotoPickStatus.success:
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) =>
                AddEditRecordScreen(imagePath: result.relativePath),
          ),
        );
      case PhotoPickStatus.cancelled:
        // 사진 선택 취소 — 홈 화면 유지.
        break;
      case PhotoPickStatus.permissionDenied:
        ToastMessage.show(context, '설정에서 사진 권한을 허용해 주세요');
      case PhotoPickStatus.error:
        ToastMessage.show(context, '사진을 불러오지 못했어요');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          // 화면 좌우 여백 20px (Design_guide.md §4.1).
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text('맛집 아카이브', style: AppTextStyles.largeTitle),
              const SizedBox(height: 12),
              _SearchField(controller: _searchController),
              const SizedBox(height: 16),
              const Expanded(child: _HomeBody()),
            ],
          ),
        ),
      ),
      floatingActionButton: _AddButton(onPressed: _onAddPressed),
    );
  }
}

/// 상단 검색창 — Surface 배경, borderRadius 10, 좌측 돋보기, 높이 36, 밑줄 없음
/// (Design_guide.md §4.2). 입력값은 [ArchiveProvider.search]로 실시간 위임한다.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.search, size: 18, color: AppColors.textSub),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: context.read<ArchiveProvider>().search,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: AppColors.primary,
              style: AppTextStyles.body,
              decoration: const InputDecoration.collapsed(
                hintText: '검색',
                hintStyle: TextStyle(
                  fontSize: 17,
                  color: AppColors.textSub,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 본문 — Provider 상태에 따라 Empty State / 그리드 / 검색 결과 없음으로 분기.
class _HomeBody extends StatelessWidget {
  const _HomeBody();

  /// 카드 탭 — 상세 화면으로 이동.
  void _openDetail(BuildContext context, ArchiveItem item) {
    // 검색 포커스를 해제해 상세에서 돌아왔을 때 키보드가 다시 뜨지 않게 한다.
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => DetailScreen(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArchiveProvider>(
      builder: (context, provider, _) {
        final items = provider.items;

        if (items.isEmpty) {
          // 검색 중이면 "결과 없음", 아니면 최초 Empty State(Task 14에서 분기 활용).
          return _EmptyState(isSearching: provider.isSearching);
        }

        return GridView.builder(
          // FAB와 겹치지 않도록 하단 여백 확보.
          padding: const EdgeInsets.only(bottom: 96),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ArchiveGridCard(
              item: item,
              onTap: () => _openDetail(context, item),
            );
          },
        );
      },
    );
  }
}

/// 데이터 0개 또는 검색 결과 없음 상태의 중앙 안내.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearching
                ? CupertinoIcons.search
                : CupertinoIcons.photo_on_rectangle,
            size: 64,
            color: AppColors.textSub,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? '검색 결과가 없습니다.' : '아직 저장된 맛집이 없어요.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSub),
          ),
        ],
      ),
    );
  }
}

/// 우하단 FAB — 56x56, Primary 배경, 은은한 그림자(Design_guide.md §4.2).
/// 기본 [FloatingActionButton] 대신 직접 그려 크기/그림자를 정확히 맞춘다.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Icon(CupertinoIcons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
