import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_fiverr/app.dart';
import 'package:mini_fiverr/screens/onboarding/onboarding_screen.dart';
import 'package:mini_fiverr/screens/splash_screen.dart';

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _loading = true;
  bool _seenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Ensure the splash screen is visible for at least 2.5 seconds
    final startTime = DateTime.now();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _seenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remaining = 2500 - elapsed;

    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _completeOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    setState(() => _seenOnboarding = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Show the splash screen during the initial load
      return const SplashScreen();
    }

    if (!_seenOnboarding) {
      return OnboardingScreen(onFinished: _completeOnboarding);
    }

    return const ProHireApp();
  }
}
