import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/archive_item.dart';
import '../utils/app_paths.dart';

/// 홈 갤러리 그리드의 카드 한 칸 (Design_guide.md §4.2).
///
/// 정사각형 썸네일(BoxFit.cover, borderRadius 8) 위에 식당명(Label)과
/// 지역명(Caption)을 세로로 배치한다. 탭하면 [onTap]으로 상세 화면 이동을
/// 위임한다(연결은 Task 9).
class ArchiveGridCard extends StatelessWidget {
  const ArchiveGridCard({super.key, required this.item, this.onTap});

  final ArchiveItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // 카드 사이 빈 곳까지 탭이 먹도록 투명 영역도 히트 테스트 대상에 포함.
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 썸네일 — 그리드 셀의 남은 높이를 채운다(Expanded). 셀 높이가
          // 고정(childAspectRatio)이라 AspectRatio 대신 Expanded를 써서
          // 텍스트 줄 수에 따른 오버플로를 원천 차단한다.
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.expand(
                child: _Thumbnail(imagePath: item.imagePath),
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
          if (item.location.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.location,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// 로컬 파일 썸네일. 파일이 없거나 디코딩에 실패하면 회색 플레이스홀더를
/// 표시하여 그리드가 깨지지 않게 한다(Task 16 Fail-Safe 선반영).
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(AppPaths.resolve(imagePath)),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const _ThumbnailPlaceholder(),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const Icon(
        CupertinoIcons.photo,
        size: 32,
        color: AppColors.textSub,
      ),
    );
  }
}
