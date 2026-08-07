import 'package:flutter/material.dart';
import '../services/auth_redirect_service.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F2),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Profile'),
          _buildSettingsCard([
            _buildListTile(Icons.person, 'Edit Profile / Personal Info', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            }),
            _buildListTile(Icons.phone, 'Update Phone Number', onTap: () => _showComingSoon(context)),
            _buildListTile(Icons.email, 'Update Email', onTap: () => _showComingSoon(context)),
          ]),
          
          _buildSectionTitle('Farm & Ponds'),
          _buildSettingsCard([
            _buildListTile(Icons.landscape, 'Edit Farm Details', onTap: () => _showComingSoon(context)),
            _buildListTile(Icons.water, 'Update Pond Details', onTap: () => _showComingSoon(context)),
            _buildListTile(Icons.set_meal, 'Change Fish Species', onTap: () => _showComingSoon(context)),
          ]),
          
          _buildSectionTitle('Security'),
          _buildSettingsCard([
            _buildListTile(Icons.lock, 'Change Password', onTap: () => _showComingSoon(context)),
            _buildListTile(
              Icons.logout,
              'Logout',
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B5E20),
          letterSpacing: 0.5,
        ),
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

  Widget _buildListTile(IconData icon, String title, {bool isDestructive = false, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withValues(alpha: 0.1) : const Color(0xFFE8F5E9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDestructive ? Colors.red : const Color(0xFF2E7D32),
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
