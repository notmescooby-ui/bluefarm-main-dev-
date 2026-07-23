import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generated automatically by FlutterFire CLI

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Catch already-initialized errors or setup errors gracefully
      print('Firebase initialization error: $e');
    }
  }
}
