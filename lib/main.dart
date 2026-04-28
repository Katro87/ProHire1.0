import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/firebase_config.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/splash_screen.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: firebaseOptions,
  );
  // Seed demo professionals if needed (safe no-op if already seeded)
  try {
    await FirestoreService().seedDemoProfessionals();
  } catch (_) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Mini Fiverr',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            error: AppColors.error,
            surface: AppColors.surface,
          ),
          fontFamily: 'Inter',
          textTheme: const TextTheme(
            headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
