import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';

import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize App Check for security - optimized for production/debug
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } catch (e) {
    debugPrint("Firebase App Check initialization failed: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()
        ..loadAllData()
        ..initializeData(),
      child: const BlueFarmApp(),
    ),
  );
}

class BlueFarmApp extends StatelessWidget {
  const BlueFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'BlueFarm',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        // Smart Routing: If logged in, go to Role Selection, otherwise Splash
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              return const RoleSelectionScreen();
            }
            return const SplashScreen();
          },
        ),
      ),
    );
  }
}
