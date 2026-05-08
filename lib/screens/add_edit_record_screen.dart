import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/ai_result.dart';
import '../models/archive_item.dart';
import '../models/exif_result.dart';
import '../providers/archive_provider.dart';
import '../services/exif_service.dart';
import '../services/location_service.dart';
import '../services/photo_service.dart';
import '../services/vision_ai_service.dart';
import '../utils/app_paths.dart';

class AddEditRecordScreen extends StatefulWidget {
  final ArchiveItem? existingItem;
  final String? imagePath;

  const AddEditRecordScreen({super.key, this.existingItem, this.imagePath});

  bool get isEditMode => existingItem != null;

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  late final TextEditingController _restaurantController;
  late final TextEditingController _locationController;
  late final TextEditingController _menuController;
  late final TextEditingController _categoryController;

  final PhotoService _photoService = PhotoService();

  late String _currentImagePath;
  DateTime? _currentDate;

  bool _isSaveEnabled = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _restaurantController = TextEditingController(text: item?.restaurantName ?? '');
    _locationController = TextEditingController(text: item?.location ?? '');
    _menuController = TextEditingController(text: item?.menuName ?? '');
    _categoryController = TextEditingController(text: item?.category ?? '');

    _currentImagePath = item?.imagePath ?? widget.imagePath ?? '';
    _currentDate = item?.date;

    _isSaveEnabled = _restaurantController.text.trim().isNotEmpty;
    _restaurantController.addListener(_onRestaurantChanged);

    if (!widget.isEditMode &&
        widget.imagePath != null &&
        widget.imagePath!.isNotEmpty) {
      _isAnalyzing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_runAnalysisPipeline(widget.imagePath!));
      });
    }
  }

  Future<void> _handleReplaceImage() async {
    if (widget.isEditMode || _isAnalyzing) return;

    final newRelative = await _photoService.pickAndPersistImage();
    if (newRelative == null) return;
    if (!mounted) return;

    final oldRelative = _currentImagePath;
    if (oldRelative.isNotEmpty && oldRelative != newRelative) {
      try {
        await File(AppPaths.resolve(oldRelative)).delete();
      } catch (_) {}
    }

    _locationController.clear();
    _menuController.clear();
    _categoryController.clear();

    setState(() {
      _currentImagePath = newRelative;
      _currentDate = null;
      _isAnalyzing = true;
    });

    unawaited(_runAnalysisPipeline(newRelative));
  }

  Future<void> _runAnalysisPipeline(String imagePath) async {
    final absolutePath = AppPaths.resolve(imagePath);
    final exifFuture = _resolveExifAndLocation(absolutePath);
    final aiFuture = VisionAIService().analyzeImage(absolutePath);

    final results = await Future.wait([exifFuture, aiFuture]);
    if (!mounted) return;

    final exifBundle = results[0] as _ExifBundle;
    final aiResult = results[1] as AiResult?;

    if (exifBundle.date != null && _currentDate == null) {
      _currentDate = exifBundle.date;
    }
    if (exifBundle.region.isNotEmpty &&
        _locationController.text.trim().isEmpty) {
      _locationController.text = exifBundle.region;
    }

    if (aiResult != null) {
      if (aiResult.menuName.isNotEmpty && _menuController.text.trim().isEmpty) {
        _menuController.text = aiResult.menuName;
      }
      if (aiResult.category.isNotEmpty &&
          _categoryController.text.trim().isEmpty) {
        _categoryController.text = aiResult.category;
      }
    }

    setState(() => _isAnalyzing = false);

    if (aiResult == null) {
      _showToast('정보를 직접 입력해 주세요');
    }
  }

  Future<_ExifBundle> _resolveExifAndLocation(String imagePath) async {
    final ExifResult exif = await ExifService().extract(imagePath);
    String region = '';
    if (exif.hasGps) {
      region = await LocationService().reverseGeocode(
        latitude: exif.latitude!,
        longitude: exif.longitude!,
      );
    }
    return _ExifBundle(date: exif.date, region: region);
  }

  void _showToast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.black.withValues(alpha: 0.85),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        ),
      );
  }

  void _onRestaurantChanged() {
    final enabled = _restaurantController.text.trim().isNotEmpty;
    if (enabled != _isSaveEnabled) {
      setState(() => _isSaveEnabled = enabled);
    }
  }

  Future<void> _handleSave() async {
    final restaurantName = _restaurantController.text.trim();
    final location = _locationController.text.trim();
    final menuName = _menuController.text.trim();
    final category = _categoryController.text.trim();

    final searchKeyword = ArchiveItem.generateSearchKeyword(
      restaurantName: restaurantName,
      menuName: menuName,
      category: category,
      location: location,
    );

    final provider = context.read<ArchiveProvider>();

    if (widget.isEditMode) {
      final existing = widget.existingItem!;
      final updated = ArchiveItem(
        id: existing.id,
        imagePath: existing.imagePath,
        restaurantName: restaurantName,
        menuName: menuName,
        category: category,
        location: location,
        date: _currentDate ?? existing.date,
        searchKeyword: searchKeyword,
      );
      await provider.updateItem(updated);
    } else {
      final item = ArchiveItem(
        id: const Uuid().v4(),
        imagePath: _currentImagePath,
        restaurantName: restaurantName,
        menuName: menuName,
        category: category,
        location: location,
        date: _currentDate,
        searchKeyword: searchKeyword,
      );
      await provider.addItem(item);
    }

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _restaurantController.dispose();
    _locationController.dispose();
    _menuController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.primary, fontSize: 17),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.isEditMode ? '기록 수정' : '새 기록',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ImagePreview(
                    imagePath: _currentImagePath,
                    onTap: widget.isEditMode ? null : _handleReplaceImage,
                    showHint:
                        !widget.isEditMode && _currentImagePath.isNotEmpty,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _restaurantController,
                    label: '식당명',
                    placeholder: '식당 이름을 입력하세요 (필수)',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _locationController,
                    label: '지역',
                    placeholder: '지역명',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _menuController,
                    label: '메뉴',
                    placeholder: '메뉴명',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _categoryController,
                    label: '카테고리',
                    placeholder: '예: 한식, 양식, 카페',
                  ),
                  const SizedBox(height: 12),
                  _DateField(date: _currentDate),
                  const SizedBox(height: 32),
                  _SaveButton(
                    enabled: _isSaveEnabled && !_isAnalyzing,
                    onPressed: _handleSave,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            if (_isAnalyzing) const _AnalyzingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.body,
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              hintText: placeholder,
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSub),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExifBundle {
  final DateTime? date;
  final String region;

  const _ExifBundle({required this.date, required this.region});
}

class _AnalyzingOverlay extends StatelessWidget {
  const _AnalyzingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.3),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(
                  radius: 16,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'AI가 사진을 분석하고 있어요...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;
  final bool showHint;

  const _ImagePreview({
    required this.imagePath,
    this.onTap,
    this.showHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (imagePath.isNotEmpty) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: Image.file(
            File(AppPaths.resolve(imagePath)),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _placeholder(),
          ),
        ),
      );
    } else {
      content = _placeholder();
    }

    final stack = Stack(
      children: [
        content,
        if (showHint)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.camera,
                    size: 14,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '사진 변경',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    if (onTap == null) return stack;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: stack,
    );
  }

  Widget _placeholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.photo,
            size: 48,
            color: AppColors.textSub,
          ),
          SizedBox(height: 8),
          Text(
            '사진이 여기에 표시됩니다',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? date;

  const _DateField({this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('날짜', style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _formatDate(date),
            style: AppTextStyles.body.copyWith(
              color: date != null ? AppColors.textMain : AppColors.textSub,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}

class _SaveButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _SaveButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? AppColors.primary : AppColors.textSub,
          disabledBackgroundColor: AppColors.textSub,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          '저장',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
