import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'web-mock-api-key',
        appId: 'web-mock-app-id',
        messagingSenderId: 'web-mock-sender-id',
        projectId: 'web-mock-project-id',
        authDomain: 'web-mock-auth-domain',
        storageBucket: 'web-mock-storage-bucket',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'android-mock-api-key',
          appId: 'android-mock-app-id',
          messagingSenderId: 'android-mock-sender-id',
          projectId: 'android-mock-project-id',
          storageBucket: 'android-mock-storage-bucket',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'ios-mock-api-key',
          appId: 'ios-mock-app-id',
          messagingSenderId: 'ios-mock-sender-id',
          projectId: 'ios-mock-project-id',
          storageBucket: 'ios-mock-storage-bucket',
          iosClientId: 'ios-mock-client-id',
          iosBundleId: 'ios-mock-bundle-id',
        );
      default:
        return const FirebaseOptions(
          apiKey: 'default-mock-api-key',
          appId: 'default-mock-app-id',
          messagingSenderId: 'default-mock-sender-id',
          projectId: 'default-mock-project-id',
        );
    }
  }
}
