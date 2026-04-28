import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/auth/login_screen.dart';
import 'package:mini_fiverr/screens/auth/security_questions_screen.dart';
import 'package:mini_fiverr/screens/dashboard/client_dashboard.dart';
import 'package:mini_fiverr/screens/dashboard/professional_dashboard.dart';
import 'package:mini_fiverr/screens/onboarding/profile_setup_step1.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await userProvider.fetchUser(authProvider.user!.uid);
      if (!mounted) return;

      final user = userProvider.userModel;
      if (user != null) {
        if (!user.hasSecurityQuestions) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SecurityQuestionsScreen(isMandatory: true)));
        } else if (!user.profileCompleted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileSetupStep1()));
        } else if (user.role == 'client') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClientDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfessionalDashboard()));
        }
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: 80, color: Colors.white)
                .animate()
                .fade(duration: 800.ms)
                .scale(delay: 200.ms),
            const SizedBox(height: 20),
            Text(
              'MINI FIVERR',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
            ).animate().fade(delay: 500.ms).slideY(begin: 0.5),
            const SizedBox(height: 50),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
