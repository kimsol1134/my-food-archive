import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/archive_provider.dart';
import '../services/photo_service.dart';
import '../widgets/archive_grid_card.dart';
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
                      return const _EmptyState();
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
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

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: TextField(
        style: AppTextStyles.body,
        cursorColor: AppColors.primary,
        textAlignVertical: TextAlignVertical.center,
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
          contentPadding:
              const EdgeInsets.only(right: 12),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.photo_on_rectangle,
            size: 64,
            color: AppColors.textSub,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 저장된 맛집이 없어요.',
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

    final imagePath = await _photoService.pickAndPersistImage();

    if (!mounted) return;
    setState(() => _busy = false);

    if (imagePath == null) return;

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => AddEditRecordScreen(imagePath: imagePath),
      ),
    );
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
