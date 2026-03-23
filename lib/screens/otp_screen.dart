import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/legacy_theme.dart';
import '../widgets/animated_bg.dart';
import '../widgets/bounce_button.dart';
import 'farmer_info_screen.dart';
import 'main_shell.dart';
import 'buyer_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _digitCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _verified = false;
  bool _loading = false;

  late AnimationController _entryCtrl;
  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _successCtrl.dispose();
    for (var c in _digitCtrls) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _digitCtrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) return;
    setState(() => _loading = true);

    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        phone: widget.phone,
        token: _otp,
        type: OtpType.sms,
      );
      if (res.session != null && mounted) {
        setState(() => _verified = true);
        _successCtrl.forward();

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          // Check if this user already completed registration
          final profile = await supa.Supabase.instance.client
              .from('profiles')
              .select('role, full_name')
              .eq('id', res.session!.user.id)
              .maybeSingle();

          if (!context.mounted) return;

          if (profile != null &&
              (profile['full_name'] as String?)?.isNotEmpty == true) {
            // Returning user — go straight to dashboard
            final role = profile['role'] as String? ?? 'farmer';
            final dest = role == 'buyer' ? BuyerShell() : const MainShell();
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                pageBuilder: (_, __, ___) => dest,
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
              (route) => false,
            );
          } else {
            // New user — go to registration
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                pageBuilder: (_, __, ___) =>
                    FarmerInfoScreen(phone: widget.phone),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP")),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Animation<double> _fadAt(double s, double e) {
    return Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(s, e, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Verify OTP"),
      ),
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fadAt(0.0, 0.4),
                    child: ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.primaryGradient.createShader(b),
                      child: const Icon(Icons.shield_rounded,
                          size: 56, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  FadeTransition(
                    opacity: _fadAt(0.1, 0.5),
                    child: Text(
                      "Enter code sent to ${widget.phone}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // OTP digit boxes
                  FadeTransition(
                    opacity: _fadAt(0.2, 0.7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          width: 46,
                          height: 56,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: _digitCtrls[i].text.isNotEmpty
                                ? AppTheme.neonBlue.withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _focusNodes[i].hasFocus
                                  ? AppTheme.neonBlue
                                  : _digitCtrls[i].text.isNotEmpty
                                      ? AppTheme.neonCyan
                                          .withValues(alpha: 0.4)
                                      : AppTheme.glassBorder,
                              width: _focusNodes[i].hasFocus ? 2 : 1,
                            ),
                            boxShadow: _focusNodes[i].hasFocus
                                ? [
                                    BoxShadow(
                                      color: AppTheme.neonBlue
                                          .withValues(alpha: 0.2),
                                      blurRadius: 12,
                                    )
                                  ]
                                : null,
                          ),
                          child: TextField(
                            controller: _digitCtrls[i],
                            focusNode: _focusNodes[i],
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            onChanged: (v) {
                              setState(() {});
                              if (v.isNotEmpty && i < 5) {
                                _focusNodes[i + 1].requestFocus();
                              }
                              if (v.isEmpty && i > 0) {
                                _focusNodes[i - 1].requestFocus();
                              }
                              if (_otp.length == 6) _verify();
                            },
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Verify button
                  FadeTransition(
                    opacity: _fadAt(0.4, 0.9),
                    child: BounceButton(
                      onPressed: _loading ? null : _verify,
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
                              : const Text(
                                  "Verify",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Success animation
                  if (_verified)
                    ScaleTransition(
                      scale: _successScale,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF00E676)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C853)
                                  .withValues(alpha: 0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 40, color: Colors.white),
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