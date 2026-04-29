import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

enum ToastType { success, error, warning, info }

class ToastService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static OverlayEntry? _entry;

  static void showSuccess(String title, {String? subtitle}) =>
      _show(title: title, subtitle: subtitle, type: ToastType.success);
  static void showError(String title, {String? subtitle}) =>
      _show(title: title, subtitle: subtitle, type: ToastType.error);
  static void showWarning(String title, {String? subtitle}) =>
      _show(title: title, subtitle: subtitle, type: ToastType.warning);
  static void showInfo(String title, {String? subtitle}) =>
      _show(title: title, subtitle: subtitle, type: ToastType.info);

  static void _show({
    required String title,
    String? subtitle,
    required ToastType type,
  }) {
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    _entry?.remove();

    _entry = OverlayEntry(
      builder: (_) => _ToastBanner(
        title: title,
        subtitle: subtitle,
        type: type,
        onClose: () => _entry?.remove(),
      ),
    );

    Overlay.of(context).insert(_entry!);
    unawaited(Future<void>.delayed(const Duration(seconds: 3), () {
      _entry?.remove();
      _entry = null;
    }));
  }
}

class _ToastBanner extends StatefulWidget {
  const _ToastBanner({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.onClose,
  });

  final String title;
  final String? subtitle;
  final ToastType type;
  final VoidCallback onClose;

  @override
  State<_ToastBanner> createState() => _ToastBannerState();
}

class _ToastBannerState extends State<_ToastBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = switch (widget.type) {
      ToastType.success => AppColors.success,
      ToastType.error => AppColors.error,
      ToastType.warning => AppColors.warning,
      ToastType.info => AppColors.secondary,
    };

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)),
          child: Dismissible(
            key: const Key('toast_dismiss'),
            direction: DismissDirection.up,
            onDismissed: (_) => widget.onClose(),
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              constraints: const BoxConstraints(maxWidth: 640),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: const Color(0xF212121A),
                borderRadius: BorderRadius.circular(14),
                border: Border(left: BorderSide(color: accent, width: 4)),
              ),
              child: ListTile(
                leading: Icon(Icons.notifications_active_rounded, color: accent),
                title: Text(widget.title, style: const TextStyle(color: Colors.white)),
                subtitle: widget.subtitle == null
                    ? null
                    : Text(widget.subtitle!, style: const TextStyle(color: AppColors.textSecondary)),
                trailing: IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
