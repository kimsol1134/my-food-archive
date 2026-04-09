import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/archive_item.dart';

class AddEditRecordScreen extends StatefulWidget {
  final ArchiveItem? existingItem;

  const AddEditRecordScreen({super.key, this.existingItem});

  bool get isEditMode => existingItem != null;

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  late final TextEditingController _restaurantController;
  late final TextEditingController _locationController;
  late final TextEditingController _menuController;
  late final TextEditingController _categoryController;

  bool _isSaveEnabled = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _restaurantController = TextEditingController(text: item?.restaurantName ?? '');
    _locationController = TextEditingController(text: item?.location ?? '');
    _menuController = TextEditingController(text: item?.menuName ?? '');
    _categoryController = TextEditingController(text: item?.category ?? '');

    _isSaveEnabled = _restaurantController.text.trim().isNotEmpty;
    _restaurantController.addListener(_onRestaurantChanged);
  }

  void _onRestaurantChanged() {
    final enabled = _restaurantController.text.trim().isNotEmpty;
    if (enabled != _isSaveEnabled) {
      setState(() => _isSaveEnabled = enabled);
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
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImagePreview(imagePath: widget.existingItem?.imagePath),
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
              _DateField(date: widget.existingItem?.date),
              const SizedBox(height: 32),
              _SaveButton(
                enabled: _isSaveEnabled,
                onPressed: () {
                  // TODO: Task 12 - 저장 로직 구현
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
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

class _ImagePreview extends StatelessWidget {
  final String? imagePath;

  const _ImagePreview({this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: Image.file(
            File(imagePath!),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _placeholder(),
          ),
        ),
      );
    }
    return _placeholder();
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
