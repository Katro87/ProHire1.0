import 'package:flutter/material.dart';

class AvatarUtils {
  static String initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '?';
    }

    final buffer = StringBuffer();
    for (final part in parts.take(2)) {
      buffer.write(part.characters.first.toUpperCase());
    }

    return buffer.toString();
  }

  static Color backgroundColorForName(String name) {
    final palette = <Color>[
      const Color(0xFF2563EB),
      const Color(0xFF0F766E),
      const Color(0xFFB45309),
      const Color(0xFF7C3AED),
      const Color(0xFFDC2626),
      const Color(0xFF0891B2),
    ];

    final index = name.trim().isEmpty ? 0 : name.codeUnits.fold<int>(0, (value, unit) => value + unit) % palette.length;
    return palette[index];
  }

  static Widget buildAvatar({
    required String name,
    String? imageUrl,
    double radius = 24,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    final initials = initialsFromName(name);
    final avatarBackground = backgroundColor ?? backgroundColorForName(name);

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: avatarBackground,
        child: Text(
          initials,
          style: textStyle ?? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarBackground.withValues(alpha: 0.12),
      foregroundImage: NetworkImage(imageUrl),
      onForegroundImageError: (_, __) {},
      child: Text(
        initials,
        style: textStyle ?? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}