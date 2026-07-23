import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up a user and create their Firestore profile
  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role, // 'farmer', 'buyer', or 'admin'
    double? farmSize,     // Optional, for farmers
    String? address,      // Optional, for farmers
  }) async {
    try {
      // 1. Create the user credentials in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        // 2. Save custom profile details under the user's Auth UID
        await _firestore.collection('users').doc(user.uid).set({
          'full_name': fullName,
          'phone': phone,
          'role': role,
          'is_approved': false, // Requires admin approval
          'farm_size_acres': farmSize,
          'location_address': address,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Error during sign up: $e");
      return null;
    }
  }
}
