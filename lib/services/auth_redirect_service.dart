import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../screens/role_selection_screen.dart';

class AuthRedirectService {
  static Future<void> signOutToRoleChooser(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const RoleSelectionScreen(),
      ),
      (route) => false,
    );
  }
}
