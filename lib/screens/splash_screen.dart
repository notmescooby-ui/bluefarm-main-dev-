import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late VideoPlayerController _videoCtrl;
  late AnimationController _introCtrl;
  
  double _progress = 0.0;
  bool _completed = false;
  double _startY = 0.0;

  @override
  void initState() {
    super.initState();
    _videoCtrl = VideoPlayerController.asset('lib/assets/splash-screen.mp4')
      ..initialize().then((_) {
        _videoCtrl.setLooping(true);
        _videoCtrl.play();
        if (mounted) setState(() {});
      });
    
    _introCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _introCtrl.forward();
    });
  }

  @override
  void dispose() {
    _videoCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }
  
  void _updateProgress(double distance) {
    if (_completed) return;
    const double threshold = 220.0;
    setState(() {
      _progress = (distance / threshold).clamp(0.0, 1.0);
    });
    if (_progress >= 1.0) {
      _completed = true;
      _navigateToLanguage();
    }
  }

  void _navigateToLanguage() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1400),
        reverseTransitionDuration: const Duration(milliseconds: 1400),
        pageBuilder: (_, __, ___) => const LanguageScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final fadeCurve = CurvedAnimation(parent: animation, curve: const Cubic(0.2, 0.8, 0.2, 1.0));
          final slideCurve = CurvedAnimation(parent: animation, curve: const Cubic(0.16, 1.0, 0.3, 1.0));
          
          return FadeTransition(
            opacity: fadeCurve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0.0),
                end: Offset.zero,
              ).animate(slideCurve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 + (_progress * 0.08);
    final translateY = -_progress * 60.0;
    final hintOpacity = (1.0 - _progress * 2.4).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragStart: (details) {
          _startY = details.globalPosition.dy;
        },
        onVerticalDragUpdate: (details) {
          final distance = _startY - details.globalPosition.dy;
          if (distance > 0) {
            _updateProgress(distance);
          }
        },
        onVerticalDragEnd: (details) {
          if (!_completed) {
            setState(() { _progress = 0.0; });
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Background
            if (_videoCtrl.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _videoCtrl.value.size.width,
                    height: _videoCtrl.value.size.height,
                    child: VideoPlayer(_videoCtrl),
                  ),
                ),
              ),

            // Content Overlay
            AnimatedBuilder(
              animation: _introCtrl,
              builder: (context, child) {
                final introCurve = CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic).value;
                return Opacity(
                  opacity: introCurve.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.95 + (0.05 * introCurve),
                    child: child,
                  ),
                );
              },
              child: SafeArea(
                child: Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scale: scale,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Swipe Up Indicator only
                        Opacity(
                          opacity: hintOpacity,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  "SWIPE UP TO ENTER",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                    letterSpacing: 3.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
