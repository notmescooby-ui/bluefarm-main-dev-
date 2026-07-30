import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/bounce_button.dart';
import 'main_shell.dart';

class DeviceConnectScreen extends StatefulWidget {
  const DeviceConnectScreen({super.key});

  @override
  State<DeviceConnectScreen> createState() => _DeviceConnectScreenState();
}

class _DeviceConnectScreenState extends State<DeviceConnectScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _pulseCtrl;

  // States: 'intro' | 'scanning' | 'found' | 'connecting' | 'connected'
  String _state = 'intro';
  String? _selectedDevice;

  final List<String> _mockDevices = [
    'BlueFarm Sensor - Pond 1',
    'BlueFarm Sensor - Tank A',
  ];

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
    )..repeat();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() => _state = 'scanning');
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _state = 'found');
      }
    });
  }

  Future<void> _connectTo(String device) async {
    setState(() {
      _selectedDevice = device;
      _state = 'connecting';
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _state = 'connected');
      // Mark as connected in state management
      await context.read<AppProvider>().setDeviceConnected(true);
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      _goToDashboard();
    }
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
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
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
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.oceanGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _buildStateContent(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_state) {
      case 'intro':
        return _buildIntroView();
      case 'scanning':
        return _buildScanningView();
      case 'found':
        return _buildFoundView();
      case 'connecting':
        return _buildConnectingView();
      case 'connected':
        return _buildConnectedView();
      default:
        return _buildIntroView();
    }
  }

  // 1. Intro View
  Widget _buildIntroView() {
    return Column(
      key: const ValueKey('intro'),
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.06).animate(
            CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
          ),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                ),
              ],
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Connect Your Device',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Turn on Bluetooth and keep the BlueFarm sensor device nearby.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        BounceButton(
          onPressed: _startScan,
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bluetooth_rounded, color: Color(0xFF1565C0)),
                SizedBox(width: 10),
                Text(
                  'Scan for Devices',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _goToDashboard, // does not set isDeviceConnected = true
          child: Text(
            'Skip for now — explore the app first',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // 2. Scanning View
  Widget _buildScanningView() {
    return Column(
      key: const ValueKey('scanning'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: List.generate(3, (index) {
                      final scale = 1.0 + (index * 0.4) + (_pulseCtrl.value * 0.4);
                      final opacity = (1.0 - (_pulseCtrl.value + index * 0.3).clamp(0.0, 1.0)) * 0.35;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: opacity),
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Scanning...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Looking for nearby BlueFarm devices',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
        ),
      ],
    );
  }

  // 3. Found Devices View
  Widget _buildFoundView() {
    return Column(
      key: const ValueKey('found'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Devices Found',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Column(
          children: _mockDevices.map((device) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: BounceButton(
                onPressed: () => _connectTo(device),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi_tethering_rounded,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D1F3C),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Ready to connect',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5A789E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF5A789E),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _startScan,
          child: Text(
            'Scan Again',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // 4. Connecting View
  Widget _buildConnectingView() {
    return Column(
      key: const ValueKey('connecting'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.18),
          ),
          child: const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Connecting...',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedDevice ?? '',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
        ),
      ],
    );
  }

  // 5. Connected View
  Widget _buildConnectedView() {
    return Column(
      key: const ValueKey('connected'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF059669),
            boxShadow: [
              BoxShadow(
                color: const Color(0x40000000),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 56,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Device Connected!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedDevice ?? '',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15),
        ),
        const SizedBox(height: 36),
        const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }
}