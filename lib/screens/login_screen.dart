import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/legacy_theme.dart';
import '../widgets/animated_bg.dart';
import '../widgets/glass_card.dart';
import '../widgets/bounce_button.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final phoneController = TextEditingController();
  late AnimationController _entryCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Animation<double> _fadAt(double start, double end) {
    return Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  Animation<Offset> _slideAt(double start, double end) {
    return Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.origin : null,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In failed: $e")),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> sendOtp() async {
    String phone = phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: phone);
      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => OtpScreen(phone: phone),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send OTP: $e")),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  FadeTransition(
                    opacity: _fadAt(0.0, 0.4),
                    child: SlideTransition(
                      position: _slideAt(0.0, 0.4),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonBlue.withValues(alpha: 0.25),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset("lib/assets/logo.png",
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  FadeTransition(
                    opacity: _fadAt(0.1, 0.5),
                    child: ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.primaryGradient.createShader(b),
                      child: const Text(
                        "BlueFarm",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  FadeTransition(
                    opacity: _fadAt(0.15, 0.55),
                    child: const Text(
                      "Your aquaculture companion",
                      style: TextStyle(
                        color: Color(0xFF3A5A7E),
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Google button
                  FadeTransition(
                    opacity: _fadAt(0.25, 0.65),
                    child: SlideTransition(
                      position: _slideAt(0.25, 0.65),
                      child: BounceButton(
                        onPressed: _loading ? null : signInWithGoogle,
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Center(
                                  child: Text("G",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4285F4),
                                      )),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "Continue with Google",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0D1F3C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Divider
                  FadeTransition(
                    opacity: _fadAt(0.35, 0.7),
                    child: const Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: AppTheme.glassBorder, thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("OR",
                              style: TextStyle(
                                color: Color(0xFF3A5A7E),
                                fontSize: 12,
                                letterSpacing: 2,
                              )),
                        ),
                        Expanded(
                            child: Divider(
                                color: AppTheme.glassBorder, thickness: 1)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Phone input
                  FadeTransition(
                    opacity: _fadAt(0.4, 0.8),
                    child: SlideTransition(
                      position: _slideAt(0.4, 0.8),
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          color: Color(0xFF0D1F3C),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "+91 XXXXXXXXXX",
                          prefixIcon: Icon(Icons.phone_rounded,
                              color: AppTheme.neonCyan.withValues(alpha: 0.6)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Phone button
                  FadeTransition(
                    opacity: _fadAt(0.5, 0.9),
                    child: SlideTransition(
                      position: _slideAt(0.5, 0.9),
                      child: BounceButton(
                        onPressed: _loading ? null : sendOtp,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.neonBlue.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color(0xFF0F172A),
                                    ),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.sms_rounded,
                                          color: Color(0xFF0F172A), size: 20),
                                      SizedBox(width: 10),
                                      Text(
                                        "Continue with Phone",
                                        style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  FadeTransition(
                    opacity: _fadAt(0.6, 1.0),
                    child: const Text(
                      "First time here? Sign up now",
                      style: TextStyle(color: Color(0xFF3A5A7E)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}