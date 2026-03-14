// File generated from google-services.json
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        // Linux uses the same config as Android for now
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwXf836LwPiUz9_ur92TDnei24XGBNUvY',
    appId: '1:71473159949:android:d8cbbee1bf9a719f635a44',
    messagingSenderId: '71473159949',
    projectId: 'studio-6301532601-f5e59',
    storageBucket: 'studio-6301532601-f5e59.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCwXf836LwPiUz9_ur92TDnei24XGBNUvY',
    appId: '1:71473159949:android:d8cbbee1bf9a719f635a44',
    messagingSenderId: '71473159949',
    projectId: 'studio-6301532601-f5e59',
    storageBucket: 'studio-6301532601-f5e59.firebasestorage.app',
  );
}
