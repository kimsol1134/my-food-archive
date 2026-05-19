import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/archive_provider.dart';
import '../services/photo_service.dart';
import '../widgets/archive_grid_card.dart';
import '../widgets/toast_message.dart';
import 'detail_screen.dart';
import 'add_edit_record_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 20,
        centerTitle: false,
        title: const Text(
          '마이 맛집 아카이브',
          style: AppTextStyles.largeTitle,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<ArchiveProvider>(
                  builder: (context, provider, _) {
                    final items = provider.items;
                    if (items.isEmpty) {
                      return provider.searchQuery.trim().isEmpty
                          ? const _EmptyState()
                          : const _NoSearchResultState();
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return ArchiveGridCard(
                          item: item,
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => DetailScreen(item: item),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const _AddFab(),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    context.read<ArchiveProvider>().search(value);
  }

  void _handleClear() {
    _controller.clear();
    context.read<ArchiveProvider>().search('');
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          _handleChanged(value);
          setState(() {});
        },
        style: AppTextStyles.body,
        cursorColor: AppColors.primary,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          hintText: '검색',
          hintStyle:
              AppTextStyles.body.copyWith(color: AppColors.textSub),
          prefixIcon: const Icon(
            CupertinoIcons.search,
            color: AppColors.textSub,
            size: 18,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          suffixIcon: hasText
              ? GestureDetector(
                  onTap: _handleClear,
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: AppColors.textSub,
                    size: 18,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          contentPadding:
              const EdgeInsets.only(right: 12),
        ),
      ),
    );
  }
}

class _EmptyState extends StatefulWidget {
  const _EmptyState();

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState> {
  final PhotoService _photoService = PhotoService();
  bool _busy = false;

  Future<void> _handleAddTap() async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await _photoService.pickAndPersistImage();

    if (!mounted) return;
    setState(() => _busy = false);

    switch (result.status) {
      case PhotoPickStatus.success:
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => AddEditRecordScreen(imagePath: result.imagePath!),
          ),
        );
      case PhotoPickStatus.permissionDenied:
        AppToast.show(context, '설정에서 사진 권한을 허용해 주세요');
      case PhotoPickStatus.cancelled:
      case PhotoPickStatus.error:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.photo_on_rectangle,
              size: 72,
              color: AppColors.textSub,
            ),
            const SizedBox(height: 20),
            Text(
              '아직 저장된 맛집이 없어요',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMain,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '사진 한 장을 골라\n첫 맛집 기록을 만들어보세요',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSub),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _handleAddTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  elevation: 0,
                ),
                icon: const Icon(CupertinoIcons.add, size: 20),
                label: const Text(
                  '첫 기록 추가',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResultState extends StatelessWidget {
  const _NoSearchResultState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 56,
            color: AppColors.textSub,
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSub),
          ),
        ],
      ),
    );
  }
}

class _AddFab extends StatefulWidget {
  const _AddFab();

  @override
  State<_AddFab> createState() => _AddFabState();
}

class _AddFabState extends State<_AddFab> {
  final PhotoService _photoService = PhotoService();
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await _photoService.pickAndPersistImage();

    if (!mounted) return;
    setState(() => _busy = false);

    switch (result.status) {
      case PhotoPickStatus.success:
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => AddEditRecordScreen(imagePath: result.imagePath!),
          ),
        );
      case PhotoPickStatus.permissionDenied:
        AppToast.show(context, '설정에서 사진 권한을 허용해 주세요');
      case PhotoPickStatus.cancelled:
      case PhotoPickStatus.error:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _handleTap,
          child: const Center(
            child: Icon(
              CupertinoIcons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
