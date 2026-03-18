import 'package:flutter/material.dart';
import '../theme/legacy_theme.dart';
import '../widgets/animated_bg.dart';
import '../widgets/bounce_button.dart';
import 'main_shell.dart';

class DeviceConnectScreen extends StatefulWidget {
  const DeviceConnectScreen({super.key});

  @override
  State<DeviceConnectScreen> createState() =>
      _DeviceConnectScreenState();
}

class _DeviceConnectScreenState extends State<DeviceConnectScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _pulseCtrl;
  bool _connecting = false;
  bool _connected  = false;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _simulateConnect() async {
    setState(() => _connecting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _connecting = false;
      _connected  = true;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    _goToDashboard();
  }

  void _goToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing device icon
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.94, end: 1.06)
                          .animate(CurvedAnimation(
                              parent: _pulseCtrl,
                              curve: Curves.easeInOut)),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _connected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF059669),
                                    Color(0xFF00897B)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: (_connected
                                      ? const Color(0xFF059669)
                                      : AppTheme.neonBlue)
                                  .withOpacity(0.38),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _connected
                              ? Icons.check_circle_rounded
                              : Icons.sensors_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _connected
                          ? 'Device Connected!'
                          : 'Connect Your Device',
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _connected
                          ? 'Your AquaBot sensor is now live.\nTaking you to your dashboard...'
                          : 'Connect your AquaBot sensor device to start monitoring your pond in real time.',
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),

                    if (!_connected) ...[
                      // Info cards
                      _infoCard(
                        Icons.wifi_rounded,
                        'Make sure your AquaBot is powered on and connected to WiFi',
                      ),
                      const SizedBox(height: 12),
                      _infoCard(
                        Icons.bluetooth_rounded,
                        'Keep your phone within 10m of the device during setup',
                      ),
                      const SizedBox(height: 32),

                      // Connect button
                      BounceButton(
                        onPressed: _connecting ? null : _simulateConnect,
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.neonBlue
                                      .withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Center(
                            child: _connecting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppTheme.deepOcean))
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.sensors_rounded,
                                          color: AppTheme.deepOcean,
                                          size: 22),
                                      SizedBox(width: 10),
                                      Text('Connect Device',
                                          style: TextStyle(
                                              color: AppTheme.deepOcean,
                                              fontSize: 17,
                                              fontWeight:
                                                  FontWeight.bold)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Skip
                      TextButton(
                        onPressed: _goToDashboard,
                        child: const Text(
                          'Skip for now — explore the app first',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF059669)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String text) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF1565C0).withOpacity(0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.15)),
    ),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF1565C0), size: 22),
      const SizedBox(width: 12),
      Expanded(
        child: Text(text,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                height: 1.4)),
      ),
    ]),
  );
}