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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _seenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
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
      return const SplashScreen(hold: true);
    }

    if (!_seenOnboarding) {
      return OnboardingScreen(onFinished: _completeOnboarding);
    }

    return const ProHireApp();
  }
}