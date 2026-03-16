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
import 'screens/admin_shell.dart';
import 'screens/pending_approval_screen.dart';

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
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) async {
        if (data.event == AuthChangeEvent.signedIn &&
            data.session != null) {
          final user = data.session!.user;

          final profile = await Supabase.instance.client
              .from('profiles')
              .select('role, full_name, account_status')
              .eq('id', user.id)
              .maybeSingle();

          if (!mounted) return;

          if (profile == null ||
              (profile['full_name'] as String?)?.isEmpty != false) {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => FarmerInfoScreen(
                  phone: user.phone ?? '',
                  email: user.email,
                ),
              ),
              (route) => false,
            );
          } else {
            final role = profile['role'] as String? ?? 'farmer';
            final status =
                profile['account_status'] as String? ?? 'active';

            Widget home;
            if (role == 'admin' && status == 'pending') {
              home = PendingApprovalScreen();
            } else if (role == 'admin' && status == 'active') {
              home = AdminShell();
            } else if (role == 'buyer') {
              home = BuyerShell();
            } else {
              home = MainShell();
            }

            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => home),
              (route) => false,
            );
          }
        }
      },
    );
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