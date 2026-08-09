import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_redirect_service.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Color themeColor;
  final Color backgroundColor;

  const SettingsScreen({
    super.key,
    required this.themeColor,
    required this.backgroundColor,
  });

  Future<void> _launchSupportEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'bluefarm1572@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'BlueFarm App Support Request',
      }),
    );

    try {
      if (!await launchUrl(emailLaunchUri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open email client')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsCard([
            _buildListTile(
              icon: Icons.person,
              title: 'Edit Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            _buildListTile(
              icon: Icons.headset_mic,
              title: 'Ask Support',
              onTap: () => _launchSupportEmail(context),
            ),
            const Divider(height: 1),
            _buildListTile(
              icon: Icons.logout,
              title: 'Log Out',
              isDestructive: true,
              onTap: () async {
                await AuthRedirectService.signOutToRoleChooser(context);
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final Color iconColor = isDestructive ? Colors.red : themeColor;
    final Color bgCircleColor = isDestructive 
        ? Colors.red.withValues(alpha: 0.1) 
        : themeColor.withValues(alpha: 0.1);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgCircleColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
