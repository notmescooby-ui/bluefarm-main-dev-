import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Use the Server Client ID from your Firebase Console screenshot
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '52765421109-cd5m2ph8br6s5fcudtlo1n4kabikmoh6.apps.googleusercontent.com',
    scopes: ['email'],
  );

  static String? lastVerificationId;

  Future<void> signInWithGoogle() async {
    try {
      debugPrint("Google Auth: Attempting sign-out of previous session...");
      await _googleSignIn.signOut();

      debugPrint("Google Auth: Opening account picker...");
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint("Google Auth: Flow cancelled by user.");
        return;
      }

      debugPrint("Google Auth: Getting authentication tokens...");
      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception(
            "Google Auth: Failed to retrieve ID Token. Check your SHA-1 and Google Cloud Console.");
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint("Google Auth: Exchanging tokens with Firebase...");

      // Added 15s timeout to prevent the 'hang' behavior
      final userCredential =
          await _auth.signInWithCredential(credential).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint(
              "Google Auth: Firebase timed out. Most likely blocked by App Check or Network.");
          throw Exception(
              "Authentication timed out. Please check if App Check is enforced in Firebase Console.");
        },
      );

      debugPrint("Google Auth: Success! User: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error (${e.code}): ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Google Auth General Error: $e");
      rethrow;
    }
  }

  // --- SMS Logic (Untouched) ---
  Future<void> verifyPhone({
    required String phone,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("Phone Auth Failed: ${e.code} - ${e.message}");
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          lastVerificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          lastVerificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint("Phone Auth Error: $e");
      onError(e.toString());
    }
  }

  Future<UserCredential> verifyOTP(
      String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
