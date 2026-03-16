import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/legacy_theme.dart';
import '../widgets/animated_bg.dart';
import 'admin_shell.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() =>
      _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  Timer? _pollTimer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkStatus(),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_checking) return;
    setState(() => _checking = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('account_status')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (profile != null && profile['account_status'] == 'active') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => AdminShell()),
          (route) => false,
        );
        return;
      } else if (profile != null &&
          profile['account_status'] == 'rejected') {
        _showRejectedDialog();
      }
    } catch (_) {}

    if (mounted) setState(() => _checking = false);
  }

  void _showRejectedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Application Rejected'),
        content: const Text(
          'Your developer account application was not approved. '
          'Please contact the BlueFarm team for more information.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Supabase.instance.client.auth.signOut(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.92, end: 1.08)
                        .animate(CurvedAnimation(
                      parent: _pulseCtrl,
                      curve: Curves.easeInOut,
                    )),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A148C).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Account Pending Approval',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your developer / admin account has been submitted '
                    'and is waiting for approval from an existing admin.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A148C).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4A148C).withOpacity(0.2),
                      ),
                    ),
                    child: Column(children: [
                      _infoRow(Icons.schedule_rounded,
                          'Typical review time: 24-48 hours'),
                      const SizedBox(height: 12),
                      _infoRow(Icons.notifications_rounded,
                          'You will be redirected automatically when approved'),
                      const SizedBox(height: 12),
                      _infoRow(Icons.verified_user_rounded,
                          'Your Aadhaar document is also under review'),
                    ]),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _checking ? null : _checkStatus,
                      icon: _checking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: Text(_checking
                          ? 'Checking...'
                          : 'Check Approval Status'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF4A148C)),
                        foregroundColor: const Color(0xFF4A148C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Supabase.instance.client.auth.signOut(),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppTheme.textSecondary),
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

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 18, color: const Color(0xFF4A148C)),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
              color: AppTheme.textPrimary, fontSize: 13),
        ),
      ),
    ],
  );
}