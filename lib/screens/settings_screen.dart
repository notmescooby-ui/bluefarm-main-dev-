import 'package:flutter/material.dart';
import '../services/auth_redirect_service.dart';
import '../services/ui_feedback_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F5),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Account Settings',
                style: TextStyle(
                  color: Color(0xFF0F1A2A),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('ACCOUNT'),
                  _buildSettingsCard(context, [
                    _buildListTile(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Details',
                      subtitle: 'Update your personal information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('SUPPORT'),
                  _buildSettingsCard(context, [
                    _buildListTile(
                      context,
                      icon: Icons.headset_mic_rounded,
                      title: 'Ask Support',
                      subtitle: 'Contact us for help and feedback',
                      onTap: () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'bluefarm1572@gmail.com',
                          query: 'subject=BlueFarm%20App%20Support%20Request',
                        );
                        try {
                          if (!await launchUrl(emailLaunchUri)) {
                            if (context.mounted) {
                              UIFeedback.showError(context, 'Could not open email client');
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            UIFeedback.showError(context, 'Could not open email client');
                          }
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('DANGER ZONE'),
                  _buildSettingsCard(context, [
                    _buildListTile(
                      context,
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      subtitle: 'Securely log out of your account',
                      isDestructive: true,
                      onTap: () async {
                        final confirm = await _showLogoutDialog(context);
                        if (confirm == true && context.mounted) {
                          await AuthRedirectService.signOutToRoleChooser(
                              context);
                          if (context.mounted) {
                            UIFeedback.showSuccess(
                                context, "Logged out successfully");
                          }
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E0)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 60, color: Color(0xFFF1F1F1));
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final color =
        isDestructive ? const Color(0xFFDC2626) : const Color(0xFF0F1A2A);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? const Color(0xFFDC2626).withValues(alpha: 0.08)
                      : const Color(0xFF1565C0).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    size: 22,
                    color: isDestructive
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF1565C0)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: Color(0xFFE5E5E0)),
            ],
          ),
        ),
      ),
    );
  }



  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out from BlueFarm?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
