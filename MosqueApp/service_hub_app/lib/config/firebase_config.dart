import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REMOVED_SECRET',
    appId: '1:185848472146:android:f6406cdea0f760bfa9f58b',
    messagingSenderId: '185848472146',
    projectId: 'mubarok-tester',
    databaseURL: 'https://mubarok-tester-default-rtdb.firebaseio.com',
    storageBucket: 'mubarok-tester.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REMOVED_SECRET',
    appId: '1:185848472146:ios:d4dehejrun2cg1jl3hqgkic824nrq5sc',
    messagingSenderId: '185848472146',
    projectId: 'mubarok-tester',
    databaseURL: 'https://mubarok-tester-default-rtdb.firebaseio.com',
    storageBucket: 'mubarok-tester.firebasestorage.app',
    iosBundleId: 'com.mubarok.tester',
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