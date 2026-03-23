import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/farmer_info_screen.dart';
import 'screens/main_shell.dart';
import 'screens/buyer_shell.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ttipwqpiwqwejvxtzqqn.supabase.co',
    anonKey: 'sb_publishable_2cW0EppUpaTpRhuumLGzMA_0JS00vKw',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()
        ..loadAllData()
        ..startRealtimeListening(),
      child: const BlueFarmApp(),
    ),
  );
}

class BlueFarmApp extends StatefulWidget {
  const BlueFarmApp({super.key});

  @override
  State<BlueFarmApp> createState() => _BlueFarmAppState();
}

class _BlueFarmAppState extends State<BlueFarmApp> {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange
        .listen((data) async {
      if (data.event == AuthChangeEvent.signedIn &&
          data.session != null) {
        final user = data.session!.user;

        // Check if user already completed registration
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('role, full_name')
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null &&
            (profile['full_name'] as String?)?.isNotEmpty == true) {
          // Returning user — go directly to their dashboard
          final role = profile['role'] as String? ?? 'farmer';
          final Widget home =
              role == 'buyer' ? BuyerShell() : const MainShell();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => home),
            (route) => false,
          );
        } else {
          // New user — go to role selection + registration
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => FarmerInfoScreen(
                phone: user.phone ?? '',
                email: user.email,
              ),
            ),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'BlueFarm',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode:
            provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}