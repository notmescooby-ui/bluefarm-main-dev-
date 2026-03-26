import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../services/auth_redirect_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_translations.dart';
import 'home_screen.dart';
import 'knowledge_screen.dart';
import 'insights_screen.dart';
import 'harvest_screen.dart';
import 'camera_screen.dart';
import 'hardware_screen.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
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

          // ── Ultra-thin white header ────────────────────────────────────────
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

          // ── Dock — 5 tabs ──────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 10),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF0A1628).withOpacity(0.92)
                            : Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 0.1
                                  : 0.6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1565C0).withOpacity(0.10),
                            blurRadius: 24,
                            offset: const Offset(0, -3),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DockItemWidget(
                            index: 0,
                            icon: Icons.home_outlined,
                            label: AppTranslations.get('home'),
                            isActive: _currentIndex == 0,
                            onTap: () => setState(() => _currentIndex = 0),
                          ),
                          DockItemWidget(
                            index: 1,
                            icon: Icons.menu_book_outlined,
                            label: AppTranslations.get('learn'),
                            isActive: _currentIndex == 1,
                            onTap: () => setState(() => _currentIndex = 1),
                          ),
                          DockItemWidget(
                            index: 2,
                            icon: Icons.insights_outlined,
                            label: AppTranslations.get('insights'),
                            isActive: _currentIndex == 2,
                            onTap: () => setState(() => _currentIndex = 2),
                          ),
                          DockItemWidget(
                            index: 3,
                            icon: Icons.storefront_outlined,
                            label: AppTranslations.get('harvest'),
                            isActive: _currentIndex == 3,
                            onTap: () => setState(() => _currentIndex = 3),
                          ),
                          DockItemWidget(
                            index: 4,
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            isActive: _currentIndex == 4,
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
    final color = widget.isActive ? AppTheme.lightAccent : Theme.of(context).textTheme.bodySmall?.color;

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

  Widget _menuRow({required IconData icon, required String label, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: AppTheme.cardDecoration(context),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.lightAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: AppTheme.lightAccent, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
            ],
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
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 140,
              decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
              child: Stack(
                children: [
                  Positioned(
                    top: -25,
                    right: -25,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                         Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [AppTheme.lightAccent, Color(0xFF6D28D9)]),
                            border: Border.all(color: Colors.white.withOpacity(0.32), width: 3),
                          ),
                          child: const Icon(Icons.person_outline, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 34),
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Consumer<AppProvider>(
                              builder: (context, p, _) => Text(
                                p.userProfile['full_name'] as String? ?? p.userProfile['name'] as String? ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Consumer<AppProvider>(
                              builder: (context, p, _) => Text(
                                '${p.userProfile['role'] as String? ?? 'Farmer'}  ·  ${p.userProfile['region'] as String? ?? p.userProfile['location'] as String? ?? 'Navi Mumbai'}',
                                style: const TextStyle(fontSize: 10, color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.lightSuccess.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.lightSuccess),
                              ),
                              child: const Text('Verified', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 13,
                    right: 13,
                    child: GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.17)),
                        child: const Icon(Icons.close, color: Colors.white, size: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _view == 'menu'
                  ? Padding(
                      padding: const EdgeInsets.all(17.0),
                      child: Column(
                        children: [
                          _menuRow(
                            icon: Icons.person_outline,
                            label: 'View and Edit Profile',
                            subtitle: 'Personal info, farm details',
                            onTap: () => setState(() => _view = 'profile'),
                          ),
                          _menuRow(
                            icon: Icons.notifications_outlined,
                            label: 'Preferences',
                            subtitle: 'Notifications and alerts',
                            onTap: () => setState(() => _view = 'prefs'),
                          ),
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
                          const SizedBox(height: 20),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                            ),
                            onPressed: _signOut,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, size: 18),
                                SizedBox(width: 8),
                                Text('Sign Out'),
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
