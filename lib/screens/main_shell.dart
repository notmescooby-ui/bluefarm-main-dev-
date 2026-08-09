import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/auth_redirect_service.dart';
import '../theme/app_theme.dart';

import 'home_screen.dart';
import 'knowledge_screen.dart';
import 'insights_screen.dart';
import 'harvest_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

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
      backgroundColor: const Color(0xFFF7F9FC), // Modern off-white background
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              const HomeScreen(),
              const InsightsScreen(),
              const KnowledgeScreen(),
              const HarvestScreen(),
              const SettingsScreen(
                themeColor: Colors.blue,
                backgroundColor: Color(0xFFF7F9FC),
              ),
            ],
          ),

          // ── Bottom Navigation Bar (React Design) ──────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 12,
                bottom: 16 + MediaQuery.of(context).padding.bottom,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F5), // Cream background
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E5E0), // Hairline border
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_filled,
                    inactiveIcon: Icons.home_outlined,
                    label: 'Home',
                    isActive: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _buildNavItem(
                    icon: Icons.show_chart,
                    inactiveIcon: Icons.show_chart,
                    label: 'Insights',
                    isActive: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _buildNavItem(
                    icon: Icons.menu_book,
                    inactiveIcon: Icons.menu_book_outlined,
                    label: 'Learn',
                    isActive: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _buildNavItem(
                    icon: Icons.shopping_bag,
                    inactiveIcon: Icons.shopping_bag_outlined,
                    label: 'Market',
                    isActive: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                  _buildNavItem(
                    icon: Icons.settings,
                    inactiveIcon: Icons.settings_outlined,
                    label: 'Settings',
                    isActive: _currentIndex == 4,
                    onTap: () => setState(() => _currentIndex = 4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData inactiveIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFF0F1A2A) : const Color(0xFF6B7280); // Ink vs Muted Ink
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? icon : inactiveIcon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
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
        color: const Color(0xFF059669).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.32)),
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
                color: const Color(0xFF059669).withValues(alpha: _opacity.value),
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
        : (isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF0D1F3C).withValues(alpha: 0.6));

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
                    color: widget.isActive ? AppTheme.lightAccent.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: widget.isActive
                        ? [BoxShadow(color: AppTheme.lightAccent.withValues(alpha: 0.3), blurRadius: 14)]
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
                        color: const Color(0xFF00B4CC).withValues(alpha: 0.42),
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
                              colors: [Colors.white.withValues(alpha: 0.3), Colors.transparent],
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
    final p = context.read<AppProvider>();
    _nameController.text = p.userProfile?['full_name'] ?? p.userProfile?['name'] ?? '';
    _farmController.text = p.userProfile?['farm_name'] ?? '';
    _emailController.text = p.userProfile?['email'] ?? '';
    _phoneController.text = p.userProfile?['phone'] ?? '';
    _speciesController.text = p.userProfile?['fish_species'] ?? '';
    _locationController.text = p.userProfile?['region'] ?? p.userProfile?['location'] ?? '';
    _pondController.text = p.userProfile?['pond_size'] ?? '';
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
            color: Colors.black.withValues(alpha: 0.03),
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
                borderSide: BorderSide(color: AppTheme.lightAccent.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
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
                color: const Color(0xFF0F2B5B).withValues(alpha: 0.65),
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
                                    p.userProfile?['full_name'] as String? ?? p.userProfile?['name'] as String? ?? 'prasuna',
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
                                    '${p.userProfile?['role'] as String? ?? 'farmer'} · ${_shortLocation(p.userProfile?['region'] ?? p.userProfile?['location'])}, Maharashtra',
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
                                    color: const Color(0xFF059669).withValues(alpha: 0.24),
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
                            color: Colors.white.withValues(alpha: 0.2),
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
                                  color: Colors.black.withValues(alpha: 0.03),
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
                                  activeThumbColor: const Color(0xFF0F2B5B),
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
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                                      _profileRowCompact('Name', p.userProfile?['full_name'] as String? ?? p.userProfile?['name'] as String?),
                                      const Divider(),
                                      _profileRowCompact('Farm Name', p.userProfile?['farm_name']),
                                      const Divider(),
                                      _profileRowCompact('Email', p.userProfile?['email']),
                                      const Divider(),
                                      _profileRowCompact('Phone', p.userProfile?['phone']),
                                      const Divider(),
                                      _profileRowCompact('Species', p.userProfile?['fish_species']),
                                      const Divider(),
                                      _profileRowCompact(
                                        'Location',
                                        _shortLocation(
                                          p.userProfile?['region'] ??
                                              p.userProfile?['location'],
                                        ),
                                      ),
                                      const Divider(),
                                      _profileRowCompact('Pond Size', p.userProfile?['pond_size']),
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
                                            color: Colors.orange.withValues(alpha: 0.1),
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
                color: AppTheme.lightSuccess.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppTheme.lightSuccess.withValues(alpha: 0.2)),
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
              border: Border.all(color: AppTheme.lightAccent.withValues(alpha: 0.5), width: 1.5, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                 Positioned.fill(child: Container(decoration: BoxDecoration(color: AppTheme.lightAccent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15)))),
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
                            colors: [Colors.transparent, AppTheme.lightAccent.withValues(alpha: 0.4), Colors.transparent],
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
