// Configuración de Firebase para Disrupton App
// Generado con los valores del google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Configuración actualizada con los valores reales del proyecto Firebase 'disrupton-new'.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  // Configuración de Web - Disrupton App
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDWm7tEGsSR2xgg909GgAFTlJjPEn5p9sI',
    appId: '1:979546276287:web:abcdef123456',
    messagingSenderId: '979546276287',
    projectId: 'disrupton-new',
    authDomain: 'disrupton-new.firebaseapp.com',
    storageBucket: 'disrupton-new.firebasestorage.app',
  );

  // Configuración de Android - Disrupton App
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDWm7tEGsSR2xgg909GgAFTlJjPEn5p9sI',
    appId: '1:979546276287:android:f6902779ede59627a1210a',
    messagingSenderId: '979546276287',
    projectId: 'disrupton-new',
    storageBucket: 'disrupton-new.firebasestorage.app',
  );

  // TEMPORAL: Reemplaza con tus valores de Firebase Console
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: '1:123456789:ios:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosClientId: 'your-ios-client-id.apps.googleusercontent.com',
    iosBundleId: 'com.example.disruptonApp',
  );
}
