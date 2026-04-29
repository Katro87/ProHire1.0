import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/auth/login_screen.dart';
import 'package:mini_fiverr/screens/splash_screen.dart';
import 'package:mini_fiverr/widgets/role_switcher.dart';
import 'package:provider/provider.dart';

class ProHireApp extends StatelessWidget {
  const ProHireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppAuthProvider, DataProvider>(
      builder: (_, AppAuthProvider auth, DataProvider data, __) {
        if (!data.isReady) {
          return const SplashScreen(hold: true);
        }

        return StreamBuilder<User?>(
          stream: auth.authStateChanges,
          builder: (_, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen(hold: true);
            }
            if (snapshot.data == null) {
              return const LoginScreen();
            }
            return const RoleSwitcher();
          },
        );
      },
    );
  }
}
