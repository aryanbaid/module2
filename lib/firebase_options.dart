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
    apiKey: 'AIzaSyD3LoOJgsNP9zlImCxAmR_8nYqByBnQVW4',
    appId: '1:721448287329:web:38d839a53cecb9bf71fe20',
    messagingSenderId: '721448287329',
    projectId: 'stake-dice-game-db640',
    authDomain: 'stake-dice-game-db640.firebaseapp.com',
    storageBucket: 'stake-dice-game-db640.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqu7YmGRrnGKc6JYujO8w3tXwQ-B9gPeg',
    appId: '1:721448287329:android:7e9786a4ffb037f371fe20',
    messagingSenderId: '721448287329',
    projectId: 'stake-dice-game-db640',
    storageBucket: 'stake-dice-game-db640.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAek_ec9fggSr5e6xDmdA1wkViiTKANCjk',
    appId: '1:721448287329:ios:268d6b8e6eee0e3b71fe20',
    messagingSenderId: '721448287329',
    projectId: 'stake-dice-game-db640',
    storageBucket: 'stake-dice-game-db640.firebasestorage.app',
    iosBundleId: 'com.example.projects',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAek_ec9fggSr5e6xDmdA1wkViiTKANCjk',
    appId: '1:721448287329:ios:268d6b8e6eee0e3b71fe20',
    messagingSenderId: '721448287329',
    projectId: 'stake-dice-game-db640',
    storageBucket: 'stake-dice-game-db640.firebasestorage.app',
    iosBundleId: 'com.example.projects',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD3LoOJgsNP9zlImCxAmR_8nYqByBnQVW4',
    appId: '1:721448287329:web:e5de9096c85ed94371fe20',
    messagingSenderId: '721448287329',
    projectId: 'stake-dice-game-db640',
    authDomain: 'stake-dice-game-db640.firebaseapp.com',
    storageBucket: 'stake-dice-game-db640.firebasestorage.app',
  );
}
