import 'dart:async';

import 'package:flutter/material.dart';

/// iOS 스타일 둥근 플로팅 토스트(Design_guide.md §5 — 스낵바 대체).
///
/// Android Material SnackBar를 쓰지 않고 [Overlay]에 직접 띄워, 화면 하단에서
/// 페이드 인/아웃하는 가벼운 토스트를 보여준다. 일정 시간 후 자동으로 사라진다.
class ToastMessage {
  const ToastMessage._();

  static const Duration _visibleDuration = Duration(milliseconds: 1800);

  /// [context]에서 가장 가까운 루트 Overlay에 토스트를 띄운다.
  static void show(BuildContext context, String message) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    showOnOverlay(overlay, message);
  }

  /// 화면 전환(pop) 직후처럼 BuildContext를 쓰기 곤란할 때를 위해, 미리 확보해 둔
  /// [OverlayState]에 직접 띄우는 변형.
  static void showOnOverlay(OverlayState overlay, String message) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(
        message: message,
        visibleDuration: _visibleDuration,
        onDismissed: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.visibleDuration,
    required this.onDismissed,
  });

  final String message;
  final Duration visibleDuration;
  final VoidCallback onDismissed;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.visibleDuration, () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // 키보드가 떠 있으면 그 위로(viewInsets.bottom), 아니면 제스처 내비 영역 위로
    // 띄워 토스트가 소프트 키보드에 가려지지 않게 한다.
    final bottomInset = media.viewInsets.bottom > 0
        ? media.viewInsets.bottom
        : media.padding.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomInset + 80,
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _controller,
            child: Container(
              constraints: BoxConstraints(maxWidth: media.size.width - 40),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
