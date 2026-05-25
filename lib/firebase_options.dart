// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // Add other platforms if needed
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLv9tJj12v_Uoj3zkHh_wwQhnkJ73eHe4',
    appId: '1:205553289227:android:8e07c5080d96f3b3381f0e',
    messagingSenderId: '205553289227',
    projectId: 'saleem-dry-clean',
    storageBucket: 'saleem-dry-clean.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArBXadZ93iLhC6-R4AyixHuZXp8c9ctBs',
    appId: '1:205553289227:ios:ec8ff06c40b3959a381f0e',
    messagingSenderId: '205553289227',
    projectId: 'saleem-dry-clean',
    storageBucket: 'saleem-dry-clean.firebasestorage.app',
    iosBundleId: 'com.saleem.dryCleanApp',
  );

  // Add configurations for other platforms if needed
}
