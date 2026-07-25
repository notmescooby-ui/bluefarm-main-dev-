import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_bg.dart';
import '../widgets/bounce_button.dart';
import '../localization/app_translations.dart';
import 'role_selection_screen.dart';

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
  late AnimationController _waveCtrl;

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
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _buttonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _buttonCtrl.forward();
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _buttonCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = index * 0.12;
    final end = (start + 0.35).clamp(0.0, 1.0);
    return Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = index * 0.12;
    final end = (start + 0.35).clamp(0.0, 1.0);
    return Tween(
      begin: const Offset(0, 0.2),
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
      body: Stack(
        children: [
          // Background Gradient (Water/Sky theme)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.oceanGradient,
              ),
            ),
          ),

          // Animated bottom waves
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 160,
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LanguageWavePainter(_waveCtrl.value),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // Translation Icon
                  FadeTransition(
                    opacity: _staggeredFade(0),
                    child: SlideTransition(
                      position: _staggeredSlide(0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.translate_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header Title
                  FadeTransition(
                    opacity: _staggeredFade(0),
                    child: const Text(
                      "Choose your language",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Subtitle
                  FadeTransition(
                    opacity: _staggeredFade(0),
                    child: Text(
                      "You can change this anytime in settings",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Language cards
                  Column(
                    children: List.generate(_languages.length, (i) {
                      final (code, title, sub, flag) = _languages[i];
                      final selected = selectedLanguage == code;

                      return FadeTransition(
                        opacity: _staggeredFade(i + 1),
                        child: SlideTransition(
                          position: _staggeredSlide(i + 1),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: BounceButton(
                              onPressed: () {
                                setState(() {
                                  selectedLanguage = code;
                                  AppTranslations.currentLanguage = code;
                                });
                              },
                              child: AnimatedScale(
                                scale: selected ? 1.03 : 1.0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutBack,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  decoration: BoxDecoration(
                                    // Highlight selected box with white/light-green background
                                    color: selected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      // Thicker green/accent border for selected box
                                      color: selected
                                          ? const Color(0xFF059669)
                                          : Colors.transparent,
                                      width: selected ? 2.5 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: selected
                                            ? Colors.black.withOpacity(0.12)
                                            : Colors.black.withOpacity(0.04),
                                        blurRadius: selected ? 24 : 10,
                                        offset: selected ? const Offset(0, 8) : const Offset(0, 4),
                                      ),
                                    ],
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
                                                    ? const Color(0xFF0D1F3C)
                                                    : const Color(0xFF5A789E),
                                              ),
                                            ),
                                            Text(
                                              sub,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: selected
                                                    ? const Color(0xFF059669).withOpacity(0.7)
                                                    : const Color(0xFF5A789E).withOpacity(0.6),
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedScale(
                                        scale: selected ? 1.0 : 0.0,
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.elasticOut,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF059669),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Continue button
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _buttonCtrl,
                      curve: Curves.easeOut,
                    ),
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _buttonCtrl,
                        curve: Curves.easeOutCubic,
                      )),
                      child: BounceButton(
                        onPressed: () {
                          AppTranslations.setLanguage(selectedLanguage);
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 600),
                              pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageWavePainter extends CustomPainter {
  final double t;
  _LanguageWavePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    for (int i = 0; i < 2; i++) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.08 - i * 0.03)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height * 0.4 +
            sin((x / size.width * 2 * pi) + (t * 2 * pi) + (i * pi)) * 12;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LanguageWavePainter old) => true;
}
