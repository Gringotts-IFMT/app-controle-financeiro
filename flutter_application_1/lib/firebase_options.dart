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
    apiKey: 'AIzaSyC1fdQ6PaN2tegYOzMdijfyhwsgEbf_fCE',
    appId: '1:375462470587:web:a380d4325684168ff19a9e',
    messagingSenderId: '375462470587',
    projectId: 'voltaic-racer-230700',
    authDomain: 'voltaic-racer-230700.firebaseapp.com',
    storageBucket: 'voltaic-racer-230700.appspot.com',
    measurementId: 'G-ZQ3GQ9P0VM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPWAbEna58zLDbulcs5cdX2LfwEtGjNNs',
    appId: '1:375462470587:android:1a4549623b53fc1ef19a9e',
    messagingSenderId: '375462470587',
    projectId: 'voltaic-racer-230700',
    storageBucket: 'voltaic-racer-230700.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDl7X2qZ0a5m-O6qX3O9v2XfoM2eDW4E3g',
    appId: '1:375462470587:ios:1c5160bad0c9ed2df19a9e',
    messagingSenderId: '375462470587',
    projectId: 'voltaic-racer-230700',
    storageBucket: 'voltaic-racer-230700.appspot.com',
    iosClientId: '375462470587-48j6lvd5ghh8c3ng19snprusvbjsb9sh.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDl7X2qZ0a5m-O6qX3O9v2XfoM2eDW4E3g',
    appId: '1:375462470587:ios:1c5160bad0c9ed2df19a9e',
    messagingSenderId: '375462470587',
    projectId: 'voltaic-racer-230700',
    storageBucket: 'voltaic-racer-230700.appspot.com',
    iosClientId: '375462470587-48j6lvd5ghh8c3ng19snprusvbjsb9sh.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC1fdQ6PaN2tegYOzMdijfyhwsgEbf_fCE',
    appId: '1:375462470587:web:e4636a4df41c3fcaf19a9e',
    messagingSenderId: '375462470587',
    projectId: 'voltaic-racer-230700',
    authDomain: 'voltaic-racer-230700.firebaseapp.com',
    storageBucket: 'voltaic-racer-230700.appspot.com',
    measurementId: 'G-VD98B1H404',
  );
}
