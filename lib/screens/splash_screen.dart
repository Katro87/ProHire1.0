import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mini_fiverr/utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.hold = false});

  final bool hold;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showSubtitle = false;

  @override
  void initState() {
    super.initState();
    unawaited(Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showSubtitle = true);
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF08080D), Color(0xFF101024)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'ProHire',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 44,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: <Color>[AppColors.primary, AppColors.secondary],
                        ).createShader(const Rect.fromLTWH(0, 0, 220, 70)),
                    ),
              ).animate(onPlay: (AnimationController c) => c.repeat(reverse: true)).fadeIn(duration: 450.ms).scaleXY(begin: 0.96, end: 1.02, duration: 1400.ms),
              const SizedBox(height: 10),
              AnimatedOpacity(
                opacity: _showSubtitle ? 1 : 0,
                duration: const Duration(milliseconds: 350),
                child: Text(
                  'Connect. Create. Earn.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                ),
              ),
              if (widget.hold) ...<Widget>[
                const SizedBox(height: 30),
                const CircularProgressIndicator(strokeWidth: 2.2),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
