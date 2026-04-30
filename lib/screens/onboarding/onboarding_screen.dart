import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_Slide> _slides = const <_Slide>[
    _Slide(
      icon: Icons.rocket_launch_rounded,
      title: 'Hire faster',
      body: 'Browse skilled professionals, favorite the ones you like, and send requests in a few taps.',
    ),
    _Slide(
      icon: Icons.security_rounded,
      title: 'Stay protected',
      body: 'Security questions, notifications, and message read states stay organized in one place.',
    ),
    _Slide(
      icon: Icons.verified_rounded,
      title: 'Work and earn',
      body: 'Professionals can track earnings, add job cards, and manage incoming work from the same app.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFF07070B), Color(0xFF101126), Color(0xFF17172D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onFinished,
                  child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (int value) => setState(() => _index = value),
                  itemBuilder: (BuildContext context, int index) {
                    final _Slide slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: <Color>[AppColors.primary, AppColors.secondary],
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 40, spreadRadius: 4),
                              ],
                            ),
                            child: Icon(slide.icon, size: 44, color: Colors.white),
                          ),
                          const SizedBox(height: 28),
                          Text(slide.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 14),
                          Text(slide.body, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(_slides.length, (int i) {
                  final bool active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.white24,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_index < _slides.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
                      } else {
                        widget.onFinished();
                      }
                    },
                    child: Text(_index < _slides.length - 1 ? 'Next' : 'Get Started'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;
}