import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REMOVED_SECRET',
    appId: '1:REMOVED_SECRET:android:6f994e1caeebba8be4f5ee',
    messagingSenderId: 'REMOVED_SECRET',
    projectId: 'REMOVED_SECRET',
    databaseURL: 'https://REMOVED_SECRET-default-rtdb.firebaseio.com',
    storageBucket: 'REMOVED_SECRET.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REMOVED_SECRET',
    appId: '1:REMOVED_SECRET:ios:7f74f2106ae09e93e4f5ee',
    messagingSenderId: 'REMOVED_SECRET',
    projectId: 'REMOVED_SECRET',
    databaseURL: 'https://REMOVED_SECRET-default-rtdb.firebaseio.com',
    storageBucket: 'REMOVED_SECRET.firebasestorage.app',
    iosBundleId: 'REMOVED_SECRET',
  );

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }
}