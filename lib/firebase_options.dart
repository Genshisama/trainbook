// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBcHZNTxNxPM4skQdK-XpT_s3lqRpx4B4A',
    appId: '1:231093320338:web:0fcb326b188e29f8aac44b',
    messagingSenderId: '231093320338',
    projectId: 'trainbook-1a841',
    authDomain: 'trainbook-1a841.firebaseapp.com',
    storageBucket: 'trainbook-1a841.firebasestorage.app',
    measurementId: 'G-HJHEG9GZLR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqrDUdAl6K4dpVbTbj76USZaJOHOTA52Q',
    appId: '1:231093320338:android:afcb93821b7fa2a6aac44b',
    messagingSenderId: '231093320338',
    projectId: 'trainbook-1a841',
    storageBucket: 'trainbook-1a841.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCY-hguDiSAYCCSUNwSOA9_5ObwSfVo1fs',
    appId: '1:231093320338:ios:7d5aafc63fc1e93eaac44b',
    messagingSenderId: '231093320338',
    projectId: 'trainbook-1a841',
    storageBucket: 'trainbook-1a841.firebasestorage.app',
    iosBundleId: 'com.example.trainbook',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCY-hguDiSAYCCSUNwSOA9_5ObwSfVo1fs',
    appId: '1:231093320338:ios:7d5aafc63fc1e93eaac44b',
    messagingSenderId: '231093320338',
    projectId: 'trainbook-1a841',
    storageBucket: 'trainbook-1a841.firebasestorage.app',
    iosBundleId: 'com.example.trainbook',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBcHZNTxNxPM4skQdK-XpT_s3lqRpx4B4A',
    appId: '1:231093320338:web:4f8f70dda414a276aac44b',
    messagingSenderId: '231093320338',
    projectId: 'trainbook-1a841',
    authDomain: 'trainbook-1a841.firebaseapp.com',
    storageBucket: 'trainbook-1a841.firebasestorage.app',
    measurementId: 'G-D9KC4FCKJY',
  );
}
