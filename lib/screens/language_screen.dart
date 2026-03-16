import 'package:flutter/material.dart';
import '../theme/legacy_theme.dart';
import '../widgets/animated_bg.dart';
import '../widgets/bounce_button.dart';
import '../localization/app_translations.dart';
import 'login_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with TickerProviderStateMixin {
  String selectedLanguage = "en";
  late AnimationController _staggerCtrl;
  late AnimationController _buttonCtrl;

  static const _languages = [
    ('en', 'English', 'ENGLISH', '🇬🇧'),
    ('hi', 'हिंदी', 'HINDI', '🇮🇳'),
    ('mr', 'मराठी', 'MARATHI', '🇮🇳'),
    ('te', 'తెలుగు', 'TELUGU', '🇮🇳'),
  ];

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _buttonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _buttonCtrl.forward();
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _buttonCtrl.dispose();
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = index * 0.15;
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = index * 0.15;
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // Header
                FadeTransition(
                  opacity: _staggeredFade(0),
                  child: SlideTransition(
                    position: _staggeredSlide(0),
                    child: ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.primaryGradient.createShader(b),
                      child: const Icon(
                        Icons.translate_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _staggeredFade(0),
                  child: Text(
                    AppTranslations.get("choose_language"),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeTransition(
                  opacity: _staggeredFade(0),
                  child: Text(
                    AppTranslations.get("select_language"),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 36),

                // Language cards
                ...List.generate(_languages.length, (i) {
                  final (code, title, sub, flag) = _languages[i];
                  final selected = selectedLanguage == code;

                  return FadeTransition(
                    opacity: _staggeredFade(i + 1),
                    child: SlideTransition(
                      position: _staggeredSlide(i + 1),
                      child: BounceButton(
                        onPressed: () {
                          setState(() {
                            selectedLanguage = code;
                            AppTranslations.currentLanguage = code;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.neonBlue.withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.neonBlue.withValues(alpha: 0.6)
                                  : Colors.white.withValues(alpha: 0.1),
                              width: selected ? 1.8 : 1,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.neonBlue
                                          .withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(flag, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: selected
                                            ? AppTheme.neonBlue
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      sub,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary
                                            .withValues(alpha: 0.6),
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedScale(
                                scale: selected ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.elasticOut,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppTheme.deepOcean,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Continue button
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _buttonCtrl,
                    curve: Curves.easeOut,
                  ),
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _buttonCtrl,
                      curve: Curves.easeOutCubic,
                    )),
                    child: BounceButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 600),
                            pageBuilder: (_, __, ___) => const LoginScreen(),
                            transitionsBuilder: (_, anim, __, child) {
                              return FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: const Offset(0.05, 0),
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
                      },
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonBlue.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            AppTranslations.get("continue"),
                            style: const TextStyle(
                              color: AppTheme.deepOcean,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}