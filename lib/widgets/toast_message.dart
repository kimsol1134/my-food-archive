import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';

class AppToast {
  AppToast._();

  static OverlayEntry? _currentEntry;

  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context, rootOverlay: true);

    _dismissCurrent();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        onCompleted: () {
          if (entry.mounted) entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void _dismissCurrent() {
    final entry = _currentEntry;
    if (entry != null && entry.mounted) {
      entry.remove();
    }
    _currentEntry = null;
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onCompleted;

  const _ToastWidget({required this.message, required this.onCompleted});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _runLifecycle();
  }

  Future<void> _runLifecycle() async {
    await _controller.forward();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    widget.onCompleted();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).padding.bottom + 80,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _controller,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
