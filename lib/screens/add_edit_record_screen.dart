import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/archive_item.dart';
import '../providers/archive_provider.dart';
import '../services/exif_service.dart';
import '../services/location_service.dart';
import '../services/photo_service.dart';
import '../services/vision_ai_service.dart';
import '../utils/app_paths.dart';
import '../widgets/toast_message.dart';

/// 2.0 기록 추가/수정 통합 화면 (IA.md §2.0, Design_guide.md §4.3).
///
/// - 생성 모드: [existingItem] == null, [imagePath]로 선택된 사진을 받는다.
///   진입 시 EXIF 추출 + AI 분석을 실행한다(Task 10·11).
/// - 수정 모드: [existingItem] != null, 기존 데이터로 폼을 채우고 AI는 돌리지 않는다.
class AddEditRecordScreen extends StatefulWidget {
  const AddEditRecordScreen({super.key, this.existingItem, this.imagePath});

  /// 수정 대상. null이면 생성 모드.
  final ArchiveItem? existingItem;

  /// 생성 모드에서 선택·복사된 이미지의 앱 디렉토리 기준 상대 경로.
  final String? imagePath;

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final TextEditingController _restaurantController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _menuController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final ExifService _exifService = ExifService();
  final LocationService _locationService = LocationService();
  final VisionAiService _visionAiService = VisionAiService();
  final PhotoService _photoService = PhotoService();

  /// 화면에 표시·저장할 이미지 상대 경로(재선택 시 갱신 — Task 15).
  String? _imagePath;

  /// EXIF에서 추출한 방문 일자(읽기 전용 표시).
  DateTime? _date;

  /// AI 분석 로딩 오버레이 표시 여부.
  bool _isAnalyzing = false;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    if (existing != null) {
      // 수정 모드: 기존 데이터로 폼 초기화.
      _restaurantController.text = existing.restaurantName;
      _locationController.text = existing.location;
      _menuController.text = existing.menuName;
      _categoryController.text = existing.category;
      _imagePath = existing.imagePath;
      _date = existing.date;
    } else {
      // 생성 모드: 선택된 사진 경로 반영 후 EXIF 추출 + 역지오코딩을 실행한다.
      // (AI 분석 + 로딩 오버레이 통합은 Task 11에서 이 흐름을 확장한다.)
      _imagePath = widget.imagePath;
      _analyzeNewPhoto();
    }
  }

  /// 생성 모드 진입 시 EXIF 추출 + 역지오코딩과 AI 분석을 병렬로 실행해
  /// 폼을 미리 채운다(Design_guide.md §4.3). 실행 동안 로딩 오버레이를 띄운다.
  /// 모든 단계가 Fail-Safe라 일부/전부 실패해도 빈 값으로 두고 흐름을 막지 않는다.
  Future<void> _analyzeNewPhoto() async {
    final path = _imagePath;
    if (path == null) return;
    final absolutePath = AppPaths.resolve(path);

    setState(() => _isAnalyzing = true);

    // EXIF/역지오코딩과 Gemini 호출을 동시에 시작한다(직렬 대기 방지).
    final metaFuture = _extractExifAndLocation(absolutePath);
    final aiFuture = _visionAiService.analyzeImage(absolutePath);
    final meta = await metaFuture;
    final ai = await aiFuture;

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _date = meta.date;
      if (meta.location.isNotEmpty) _locationController.text = meta.location;
      if (ai != null) {
        if (ai.menuName.isNotEmpty) _menuController.text = ai.menuName;
        if (ai.category.isNotEmpty) _categoryController.text = ai.category;
      }
    });
    // AI 분석 실패(네트워크/미구성/파싱 실패) 시 직접 입력 안내.
    if (ai == null) {
      ToastMessage.show(context, '정보를 직접 입력해 주세요');
    }
  }

  /// EXIF 날짜와 (좌표가 있으면) 역지오코딩 지역명을 함께 추출한다.
  Future<({DateTime? date, String location})> _extractExifAndLocation(
    String absolutePath,
  ) async {
    final exif = await _exifService.extractMetadata(absolutePath);
    var location = '';
    if (exif.hasCoordinates) {
      location = await _locationService.reverseGeocode(
        latitude: exif.latitude!,
        longitude: exif.longitude!,
      );
    }
    return (date: exif.date, location: location);
  }

  /// 사진 재선택(생성 모드 전용 — Task 15). 새 사진을 고르면 이전 복사본을
  /// 지우고 AI/EXIF 분석을 다시 돌려 폼을 덮어쓴다. 식당명은 유지한다.
  /// 취소/오류 시 기존 상태를 그대로 둔다.
  Future<void> _onRepickPhoto() async {
    final result = await _photoService.pickAndPersistImage();
    if (!mounted) return;
    if (result.status != PhotoPickStatus.success ||
        result.relativePath == null) {
      return; // 취소·권한거부·오류 → 기존 상태 유지.
    }

    final previous = _imagePath;
    setState(() => _imagePath = result.relativePath);
    if (previous != null && previous != result.relativePath) {
      await _deleteImageFile(previous);
    }
    await _analyzeNewPhoto();
  }

  /// 앱 디렉토리에 복사해 둔 이미지 파일을 삭제한다(실패는 무시).
  Future<void> _deleteImageFile(String relativePath) async {
    if (relativePath.isEmpty) return;
    try {
      final file = File(AppPaths.resolve(relativePath));
      if (await file.exists()) await file.delete();
    } catch (_) {
      // 파일 삭제 실패는 치명적이지 않으므로 무시.
    }
  }

  @override
  void dispose() {
    _restaurantController.dispose();
    _locationController.dispose();
    _menuController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  /// 저장 — 생성/수정 모드에 따라 ArchiveItem을 만들어 Provider에 반영한 뒤
  /// 홈 화면까지 한 번에 복귀한다(searchKeyword는 ArchiveItem 생성자가 자동 생성).
  Future<void> _onSave() async {
    final name = _restaurantController.text.trim();
    if (name.isEmpty) return; // 저장 버튼이 비활성이라 도달하지 않지만 방어적으로.

    final provider = context.read<ArchiveProvider>();
    final navigator = Navigator.of(context);

    final existing = widget.existingItem;
    if (existing != null) {
      // 수정: id/imagePath는 유지하고 나머지 필드만 갱신.
      await provider.updateItem(
        existing.copyWith(
          restaurantName: name,
          menuName: _menuController.text.trim(),
          category: _categoryController.text.trim(),
          location: _locationController.text.trim(),
        ),
      );
    } else {
      // 생성: 새 UUID로 ArchiveItem을 만든다.
      await provider.addItem(
        ArchiveItem(
          id: const Uuid().v4(),
          imagePath: _imagePath ?? '',
          restaurantName: name,
          menuName: _menuController.text.trim(),
          category: _categoryController.text.trim(),
          location: _locationController.text.trim(),
          date: _date,
        ),
      );
    }

    if (!mounted) return;
    // 입력 포커스를 내려 홈 복귀 후 키보드가 남지 않게 한다.
    FocusManager.instance.primaryFocus?.unfocus();
    ToastMessage.show(context, '저장되었습니다');
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 빈 영역 터치 시 키보드 내림(Design_guide.md §5).
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 80,
          leading: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: () {
              // 취소로 빠져나갈 때도 키보드를 내려 홈에 잔존하지 않게 한다.
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
            child: const Text(
              '취소',
              style: TextStyle(fontSize: 17, color: AppColors.primary),
            ),
          ),
          title: Text(_isEditing ? '기록 수정' : '새 기록'),
          titleTextStyle: AppTextStyles.label,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PhotoPreview(
                            imagePath: _imagePath,
                            // 재선택은 생성 모드에서만 허용(수정 모드는 사진 고정).
                            onTap: _isEditing ? null : _onRepickPhoto,
                          ),
                          const SizedBox(height: 20),
                          _FormField(
                            label: '식당명',
                            controller: _restaurantController,
                            hint: '식당 이름을 입력하세요 (필수)',
                          ),
                          _FormField(
                            label: '지역',
                            controller: _locationController,
                            hint: '예: 연남동',
                          ),
                          _FormField(
                            label: '메뉴',
                            controller: _menuController,
                            hint: '예: 크림파스타',
                          ),
                          _FormField(
                            label: '카테고리',
                            controller: _categoryController,
                            hint: '예: 양식',
                          ),
                          _DateField(date: _date),
                        ],
                      ),
                    ),
                  ),
                  _SaveButton(
                    restaurantController: _restaurantController,
                    onSave: _onSave,
                  ),
                ],
              ),
            ),
            if (_isAnalyzing) const _AnalyzingOverlay(),
          ],
        ),
      ),
    );
  }
}

/// 선택된 사진 미리보기(또는 빈 플레이스홀더).
/// [onTap]이 주어지면(생성 모드) 탭으로 사진을 재선택할 수 있고, 우하단에
/// "사진 변경" 배지를 보여준다.
class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.imagePath, this.onTap});

  final String? imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: double.infinity,
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              path == null
                  ? _placeholder()
                  : Image.file(
                      File(AppPaths.resolve(path)),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholder(),
                    ),
              if (onTap != null)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '사진 변경',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: const Icon(
          CupertinoIcons.photo,
          size: 48,
          color: AppColors.textSub,
        ),
      );
}

/// 라벨(Caption) + iOS 스타일 입력창(CupertinoTextField, Surface 배경, radius 10).
class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 6),
          CupertinoTextField(
            controller: controller,
            placeholder: hint,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            style: AppTextStyles.body,
            placeholderStyle: AppTextStyles.body.copyWith(color: AppColors.textSub),
            cursorColor: AppColors.primary,
            maxLines: 1,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}

/// 날짜(읽기 전용) — EXIF 값이 있으면 한국어 표기, 없으면 안내 문구.
class _DateField extends StatelessWidget {
  const _DateField({required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? '날짜 정보 없음'
        : '${date!.year}년 ${date!.month}월 ${date!.day}일';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('날짜', style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: date == null ? AppColors.textSub : AppColors.textMain,
            ),
          ),
        ),
      ],
    );
  }
}

/// 하단 저장 버튼 — 식당명이 비어있으면 Text Sub 배경 + 비활성화,
/// 입력되면 Primary 배경 + 활성화(Design_guide.md §4.3 필수 입력 제어).
class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.restaurantController, required this.onSave});

  final TextEditingController restaurantController;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: ListenableBuilder(
        listenable: restaurantController,
        builder: (context, _) {
          final enabled = restaurantController.text.trim().isNotEmpty;
          return GestureDetector(
            onTap: enabled ? onSave : null,
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: enabled ? AppColors.primary : AppColors.textSub,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '저장',
                style: AppTextStyles.label.copyWith(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// AI 분석 로딩 오버레이 — 반투명 검정 + 인디케이터 + 안내 문구.
/// [AbsorbPointer]로 하단 화면의 터치를 완전히 차단한다(Design_guide.md §4.3).
class _AnalyzingOverlay extends StatelessWidget {
  const _AnalyzingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(color: Colors.white, radius: 16),
              const SizedBox(height: 16),
              Text(
                'AI가 사진을 분석하고 있어요...',
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
