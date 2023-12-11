// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBPD_LjhFthAkrbprENpc4XdXKJFIVR0-k',
    appId: '1:463273095625:web:59a04f8aeb094814437818',
    messagingSenderId: '463273095625',
    projectId: 'rbc-attendance',
    authDomain: 'rbc-attendance.firebaseapp.com',
    storageBucket: 'rbc-attendance.appspot.com',
    measurementId: 'G-SQZGDEW464',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzY4eFiGV98X3yRWijfrBib5vFJrtsBEo',
    appId: '1:463273095625:android:6bb81f3bea841bc1437818',
    messagingSenderId: '463273095625',
    projectId: 'rbc-attendance',
    storageBucket: 'rbc-attendance.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQWLZoTNSqSKcC_5ZRWpBIJBj8-FtFKPU',
    appId: '1:463273095625:ios:4a3c9c7a375c7060437818',
    messagingSenderId: '463273095625',
    projectId: 'rbc-attendance',
    storageBucket: 'rbc-attendance.appspot.com',
    iosBundleId: 'com.example.rbcAtted',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQWLZoTNSqSKcC_5ZRWpBIJBj8-FtFKPU',
    appId: '1:463273095625:ios:169ca7709cb59b20437818',
    messagingSenderId: '463273095625',
    projectId: 'rbc-attendance',
    storageBucket: 'rbc-attendance.appspot.com',
    iosBundleId: 'com.example.rbcAtted.RunnerTests',
  );
}