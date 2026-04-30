import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/app.dart';
import 'package:mini_fiverr/firebase_config.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/chat_provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/startup_gate.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/widgets/toast_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: firebaseOptions,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>(create: (_) => AppAuthProvider()),
        ChangeNotifierProxyProvider<AppAuthProvider, DataProvider>(
          create: (_) => DataProvider(),
          update: (_, AppAuthProvider auth, DataProvider? data) {
            final DataProvider provider = data ?? DataProvider();
            provider.syncWithAuth(auth.user);
            return provider;
          },
        ),
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'ProHire',
        debugShowCheckedModeBanner: false,
        navigatorKey: ToastService.navigatorKey,
        theme: buildAppTheme(),
        home: const StartupGate(),
      ),
    );
  }
}
