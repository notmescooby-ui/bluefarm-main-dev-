import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../services/auth_redirect_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_translations.dart';
import '../services/supabase_compatibility.dart';
import 'home_screen.dart';
import 'knowledge_screen.dart';
import 'insights_screen.dart';
import 'harvest_screen.dart';
import 'camera_screen.dart';
import 'hardware_screen.dart';
import 'device_connect_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _sidebarOpen = false;

  final List<String> _titles = [
    'Water Quality Dashboard',
    'Knowledge Center',
    'Insights & Trends',
    'Harvest & Market',
    'Farm Camera',
  ];

  String _shortLocation(dynamic value) {
    final text = (value as String?)?.trim() ?? '';
    if (text.isEmpty) return 'Navi Mumbai';
    return text.split(',').first.trim();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isHome = _currentIndex == 0;
    final gradient = isHome ? AppTheme.homeScreenGradient : AppTheme.otherScreensGradient;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(),
                Padding(
                  padding: const EdgeInsets.only(top: 68),
                  child: KnowledgeScreen(),
                ),
                InsightsScreen(),
                HarvestScreen(),
                const CameraScreen(),
              ],
            ),

            // ── Ultra-thin white header (hidden on Dashboard/HomeScreen) ──────────────────
            if (!isHome)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Consumer<AppProvider>(
                  builder: (context, provider, _) => Container(
                    color: Colors.white,
                    child: SafeArea(
                      bottom: false,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _sidebarOpen = true),
                              child: Container(
                                width: 30, height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1565C0).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person_outline,
                                    color: Color(0xFF1565C0), size: 16),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    provider.userProfile['full_name'] as String? ??
                                        provider.userProfile['farm_name'] as String? ?? 'BlueFarm',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0D1F3C),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    _shortLocation(
                                      provider.userProfile['region'] ??
                                          provider.userProfile['location'],
                                    ),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            const LiveBadgeWidget(),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => _sidebarOpen = true),
                              child: Container(
                                width: 30, height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1565C0).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.settings_outlined,
                                    color: Color(0xFF1565C0), size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Floating Glassmorphic Bottom Navigation Bar (Fisflow Style) ──────────────────
            Positioned(
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              left: 16,
              right: 16,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(
                              icon: Icons.home_outlined,
                              label: 'Dashboard',
                              isActive: _currentIndex == 0,
                              onTap: () => setState(() => _currentIndex = 0),
                            ),
                            _buildNavItem(
                              icon: Icons.insights_outlined,
                              label: 'Insights',
                              isActive: _currentIndex == 2,
                              onTap: () => setState(() => _currentIndex = 2),
                            ),
                            _buildCenterAddButton(),
                            _buildNavItem(
                              icon: Icons.storefront_outlined,
                              label: 'Market',
                              isActive: _currentIndex == 3,
                              onTap: () => setState(() => _currentIndex = 3),
                            ),
                            _buildNavItem(
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              isActive: _sidebarOpen,
                              onTap: () => setState(() => _sidebarOpen = true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Sidebar ────────────────────────────────────────────────────────
            if (_sidebarOpen)
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _sidebarOpen = false),
                    child: Container(
                      color: Colors.black.withOpacity(0.42),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0, top: 0, bottom: 0, width: 305,
                    child: SidebarWidget(
                        onClose: () => setState(() => _sidebarOpen = false)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? Colors.white : Colors.white.withOpacity(0.6);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: _showAddActionSheet,
      child: Transform.translate(
        offset: const Offset(0, -18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22D3EE).withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF22D3EE), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: const Color(0xFF002B5B),
                  width: 4,
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628).withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Add data manually or connect options",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildActionOption(
                    icon: Icons.edit_note_rounded,
                    title: "Manual Sensor Reading",
                    subtitle: "Manually input current pH, Temp, Turbidity",
                    color: const Color(0xFF22D3EE),
                    onTap: () {
                      Navigator.pop(context);
                      _showManualEntryDialog();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionOption(
                    icon: Icons.wifi_find_rounded,
                    title: "Connect AquaBot Device",
                    subtitle: "Pair and setup real-time telemetry",
                    color: const Color(0xFF2563EB),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DeviceConnectScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionOption(
                    icon: Icons.camera_alt_outlined,
                    title: "Analyze via Camera",
                    subtitle: "Perform AI diagnostics via photo scan",
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 4);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.4), size: 18),
          ],
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final phCtrl = TextEditingController(text: "7.2");
    final tempCtrl = TextEditingController(text: "28.5");
    final turbCtrl = TextEditingController(text: "2.5");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1F3C).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Sensor Reading",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enter current water measurements manually.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDialogField("pH Level (e.g. 7.2)", phCtrl, TextInputType.number),
                    const SizedBox(height: 14),
                    _buildDialogField("Temperature (°C) (e.g. 28.5)", tempCtrl, TextInputType.number),
                    const SizedBox(height: 14),
                    _buildDialogField("Turbidity (NTU) (e.g. 2.5)", turbCtrl, TextInputType.number),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white.withOpacity(0.6)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22D3EE),
                            foregroundColor: const Color(0xFF0D1F3C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () async {
                            final phVal = double.tryParse(phCtrl.text) ?? 7.2;
                            final tempVal = double.tryParse(tempCtrl.text) ?? 28.5;
                            final turbVal = double.tryParse(turbCtrl.text) ?? 2.5;

                            try {
                              await Supabase.instance.client.from('sensor_readings').insert({
                                'created_at': DateTime.now().toIso8601String(),
                                'ph': phVal,
                                'temperature': tempVal,
                                'turbidity': turbVal,
                                'device_id': 'manual-entry',
                              });
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Reading saved successfully!"),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Failed to save reading: $e"),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            "Save Reading",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogField(String label, TextEditingController ctrl, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF22D3EE)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── LIVE BADGE ──────────────────────────────────────────────────────────────

class LiveBadgeWidget extends StatefulWidget {
  const LiveBadgeWidget({super.key});

  @override
  State<LiveBadgeWidget> createState() => _LiveBadgeWidgetState();
}

class _LiveBadgeWidgetState extends State<LiveBadgeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withOpacity(0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFF059669).withOpacity(0.32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _opacity,
            builder: (context, child) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(_opacity.value),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'LIVE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF059669), fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// ─── DOCK ITEM ───────────────────────────────────────────────────────────────

class DockItemWidget extends StatefulWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const DockItemWidget({
    super.key,
    required this.index,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<DockItemWidget> createState() => _DockItemWidgetState();
}

class _DockItemWidgetState extends State<DockItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    final curve = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.25)).animate(curve);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    widget.onTap();
    await _controller.forward();
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.isActive
        ? (isDark ? const Color(0xFF22D3EE) : const Color(0xFF1565C0))
        : (isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF0D1F3C).withOpacity(0.6));

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    color: widget.isActive ? AppTheme.lightAccent.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: widget.isActive
                        ? [BoxShadow(color: AppTheme.lightAccent.withOpacity(0.3), blurRadius: 14)]
                        : [],
                  ),
                  child: Icon(widget.icon, size: 22, color: color),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
                ),
                if (widget.isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(color: AppTheme.lightAccent, shape: BoxShape.circle),
                  )
                else
                  const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AADHAAR CENTER BUTTON ───────────────────────────────────────────────────

class AadhaarCenterButton extends StatefulWidget {
  const AadhaarCenterButton({super.key});

  @override
  State<AadhaarCenterButton> createState() => _AadhaarCenterButtonState();
}

class _AadhaarCenterButtonState extends State<AadhaarCenterButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AadhaarSheet(),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
                    gradient: LinearGradient(
                      colors: const [Color(0xFF00B4CC), Color(0xFF1565C0), Color(0xFF7C3AED)],
                      stops: [
                        0.0,
                        0.5 + (_controller.value * 0.5),
                        1.0,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00B4CC).withOpacity(0.42),
                        blurRadius: 26,
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -10,
                        left: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(Icons.credit_card_outlined, size: 28, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Text('Aadhaar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.lightAccent)),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ─── SIDEBAR WIDGET ──────────────────────────────────────────────────────────

class SidebarWidget extends StatefulWidget {
  final VoidCallback onClose;
  const SidebarWidget({super.key, required this.onClose});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  String _view = 'menu';
  bool _saved = false;

  final _nameController = TextEditingController();
  final _farmController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _speciesController = TextEditingController();
  final _locationController = TextEditingController();
  final _pondController = TextEditingController();

  String _shortLocation(dynamic value) {
    final text = (value as String?)?.trim() ?? '';
    if (text.isEmpty) return 'Navi Mumbai';
    return text.split(',').first.trim();
  }

  @override
  void initState() {
    super.initState();
    final p = context.read<AppProvider>().userProfile;
    _nameController.text = p['full_name'] ?? p['name'] ?? '';
    _farmController.text = p['farm_name'] ?? '';
    _emailController.text = p['email'] ?? '';
    _phoneController.text = p['phone'] ?? '';
    _speciesController.text = p['fish_species'] ?? '';
    _locationController.text = p['region'] ?? p['location'] ?? '';
    _pondController.text = p['pond_size'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _farmController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _speciesController.dispose();
    _locationController.dispose();
    _pondController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      await context.read<AppProvider>().updateProfile({
        'full_name': _nameController.text.trim(),
        'name': _nameController.text.trim(),
        'farm_name': _farmController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'fish_species': _speciesController.text.trim(),
        'region': _locationController.text.trim(),
        'pond_size': _pondController.text.trim(),
      });
      if (!mounted) return;
      setState(() => _saved = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _saved = false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save profile: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await AuthRedirectService.signOutToRoleChooser(context);
  }

  Widget _menuRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF0F2B5B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: AppTheme.lightAccent.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: AppTheme.lightAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF0F9FF),
            Color(0xFFE0F2FE),
            Color(0xFFBAE6FD),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Mockup Styled Header
            Container(
              height: 210,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=600&auto=format&fit=crop",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: const Color(0xFF0F2B5B).withOpacity(0.65),
                child: Stack(
                  children: [
                    // Profile Info Box
                    Positioned(
                      bottom: 24,
                      left: 18,
                      right: 18,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF22D3EE), Color(0xFF2563EB), Color(0xFF7C3AED)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1565C0),
                              ),
                              child: const Icon(Icons.person_outline, color: Colors.white, size: 30),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Consumer<AppProvider>(
                                  builder: (context, p, _) => Text(
                                    p.userProfile['full_name'] as String? ?? p.userProfile['name'] as String? ?? 'prasuna',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Consumer<AppProvider>(
                                  builder: (context, p, _) => Text(
                                    '${p.userProfile['role'] as String? ?? 'farmer'} · ${_shortLocation(p.userProfile['region'] ?? p.userProfile['location'])}, Maharashtra',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF059669).withOpacity(0.24),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF059669), width: 1),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_rounded, color: Color(0xFF34D399), size: 10),
                                      SizedBox(width: 4),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 14,
                      child: GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: _view == 'menu'
                  ? Padding(
                      padding: const EdgeInsets.all(17.0),
                      child: Column(
                        children: [
                          _menuRow(
                            icon: Icons.person_outline_rounded,
                            label: 'View and Edit Profile',
                            subtitle: 'Personal info, farm details',
                            iconColor: const Color(0xFF0284C7),
                            iconBgColor: const Color(0xFFE0F2FE),
                            onTap: () => setState(() => _view = 'profile'),
                          ),
                          _menuRow(
                            icon: Icons.notifications_none_rounded,
                            label: 'Preferences',
                            subtitle: 'Notifications and alerts',
                            iconColor: const Color(0xFF0284C7),
                            iconBgColor: const Color(0xFFE0F2FE),
                            onTap: () => setState(() => _view = 'prefs'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFD97706), size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Theme',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: Color(0xFF0F2B5B),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text('Light / Dark Mode', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: context.watch<AppProvider>().isDarkMode,
                                  onChanged: (_) => context.read<AppProvider>().toggleDarkMode(),
                                  activeColor: const Color(0xFF0F2B5B),
                                  activeTrackColor: const Color(0xFFBAE6FD),
                                  inactiveThumbColor: Colors.grey.shade400,
                                  inactiveTrackColor: Colors.grey.shade200,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: const Color(0xFF2563EB),
                            ),
                            onPressed: _signOut,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : _view == 'profile'
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.all(17),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => setState(() => _view = 'menu'),
                                icon: const Icon(Icons.arrow_back, size: 16),
                                label: const Text('Back'),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                              ),
                              const SizedBox(height: 10),
                              const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              Container(
                                decoration: AppTheme.cardDecoration(context),
                                padding: const EdgeInsets.all(14),
                                child: Consumer<AppProvider>(
                                  builder: (context, p, _) => Column(
                                    children: [
                                      _profileRowCompact('Name', p.userProfile['full_name'] as String? ?? p.userProfile['name'] as String?),
                                      const Divider(),
                                      _profileRowCompact('Farm Name', p.userProfile['farm_name']),
                                      const Divider(),
                                      _profileRowCompact('Email', p.userProfile['email']),
                                      const Divider(),
                                      _profileRowCompact('Phone', p.userProfile['phone']),
                                      const Divider(),
                                      _profileRowCompact('Species', p.userProfile['fish_species']),
                                      const Divider(),
                                      _profileRowCompact(
                                        'Location',
                                        _shortLocation(
                                          p.userProfile['region'] ??
                                              p.userProfile['location'],
                                        ),
                                      ),
                                      const Divider(),
                                      _profileRowCompact('Pond Size', p.userProfile['pond_size']),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: AppTheme.lightAccent),
                                  SizedBox(width: 8),
                                  Text('Edit Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildEditField('Full Name', _nameController),
                              _buildEditField('Farm Name', _farmController),
                              _buildEditField('Email', _emailController),
                              _buildEditField('Phone', _phoneController),
                              _buildEditField('Species', _speciesController),
                              _buildEditField('Location', _locationController),
                              _buildEditField('Pond Size', _pondController),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.lightAccent,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                ),
                                child: Text(_saved ? 'Saved!' : 'Save Changes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(17),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               OutlinedButton.icon(
                                onPressed: () => setState(() => _view = 'menu'),
                                icon: const Icon(Icons.arrow_back, size: 16),
                                label: const Text('Back'),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                              ),
                              const SizedBox(height: 10),
                              const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                               Text('APPEARANCE', style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 9),
                              Container(
                                padding: const EdgeInsets.all(13),
                                decoration: AppTheme.cardDecoration(context),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(11),
                                          ),
                                          child: const Icon(Icons.light_mode_outlined, color: Colors.orange, size: 20),
                                        ),
                                        const SizedBox(width: 11),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Theme', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                            Text('Light / Dark Mode', style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: context.watch<AppProvider>().isDarkMode,
                                      onChanged: (_) => context.read<AppProvider>().toggleDarkMode(),
                                      activeThumbColor: AppTheme.lightAccent,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                               Text('NOTIFICATIONS', style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 9),
                              SwitchListTile(
                                title: const Text('Push Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                subtitle: const Text('Farm status updates', style: TextStyle(fontSize: 11)),
                                value: true,
                                onChanged: (v){},
                                activeThumbColor: AppTheme.lightAccent,
                                contentPadding: EdgeInsets.zero,
                              ),
                              SwitchListTile(
                                title: const Text('Sensor Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                subtitle: const Text('Critical parameter changes', style: TextStyle(fontSize: 11)),
                                value: true,
                                onChanged: (v){},
                                activeThumbColor: AppTheme.lightAccent,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ]
                          )
                        )
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w700)),
          Text(value ?? '—', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _profileRowCompact(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value ?? '-',
              textAlign: TextAlign.right,
              softWrap: true,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AADHAAR BOTTOM SHEET ────────────────────────────────────────────────────

class AadhaarSheet extends StatefulWidget {
  const AadhaarSheet({super.key});

  @override
  State<AadhaarSheet> createState() => _AadhaarSheetState();
}

class _AadhaarSheetState extends State<AadhaarSheet> with SingleTickerProviderStateMixin {
  bool _scanning = false;
  bool _done = false;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() => _scanning = true);
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() { _scanning = false; _done = true; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.lightSuccess, size: 60),
            const SizedBox(height: 10),
            const Text('Verification Complete', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppTheme.lightSuccess.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppTheme.lightSuccess.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Name:'), Text('Rajesh Kumar', style: TextStyle(fontWeight: FontWeight.w800))]),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Aadhaar:'), Text('XXXX XXXX 4521', style: TextStyle(fontWeight: FontWeight.w800))]),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('DOB:'), Text('15/03/1985', style: TextStyle(fontWeight: FontWeight.w800))]),
                  Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('State:'), Text('Maharashtra', style: TextStyle(fontWeight: FontWeight.w800))]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: const Text('Continue to App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.lightPrimaryMid, AppTheme.lightAccent]),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(Icons.credit_card_outlined, size: 26, color: Colors.white),
          ),
          const SizedBox(height: 13),
          const Text('Aadhaar Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text('Scan your Aadhaar card to unlock government subsidies and verified buyer status.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
          const SizedBox(height: 18),
          Container(
            height: 165,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lightAccent.withOpacity(0.5), width: 1.5, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                 Positioned.fill(child: Container(decoration: BoxDecoration(color: AppTheme.lightAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(15)))),
                if (_scanning)
                  AnimatedBuilder(
                    animation: _scanController,
                    builder: (context, child) => Positioned(
                      top: 165 * _scanController.value - 20,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, AppTheme.lightAccent.withOpacity(0.4), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_scanning) const CircularProgressIndicator(color: AppTheme.lightAccent) else const Icon(Icons.credit_card_outlined, color: AppTheme.lightAccent, size: 40),
                      const SizedBox(height: 10),
                      Text(_scanning ? 'Scanning...' : 'Position card here', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.lightAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _scanning ? null : _startScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightAccent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
            child: Text(_scanning ? 'Scanning...' : 'Scan Card', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 9),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
