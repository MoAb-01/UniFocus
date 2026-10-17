import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return web;
    }
  }

  // Configuration settings for UniFocus Firebase project

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBR2iZwUC66Rn_A093zUZ0uPm-JYKrlVk',
    appId: '1:67992158660:web:4ba5898fea9472ed3c6491',
    messagingSenderId: '67992158660',
    projectId: 'unifocus-app',
    authDomain: 'unifocus-app.firebaseapp.com',
    storageBucket: 'unifocus-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9m9Xb7vS6P0HluRXuG43pU_yqZWeYFbI',
    appId: '1:67992158660:android:20391caffd106d713c6491',
    messagingSenderId: '67992158660',
    projectId: 'unifocus-app',
    storageBucket: 'unifocus-app.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD3zQaspAGMyK-I8CVIxhUfgt7hqI7tsxc',
    appId: '1:67992158660:ios:4bd31c4f5449a0e33c6491',
    messagingSenderId: '67992158660',
    projectId: 'unifocus-app',
    storageBucket: 'unifocus-app.firebasestorage.app',
    iosBundleId: 'com.unifocus.unifocus',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD3zQaspAGMyK-I8CVIxhUfgt7hqI7tsxc',
    appId: '1:67992158660:ios:4bd31c4f5449a0e33c6491',
    messagingSenderId: '67992158660',
    projectId: 'unifocus-app',
    storageBucket: 'unifocus-app.firebasestorage.app',
    iosBundleId: 'com.unifocus.unifocus',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCBR2iZwUC66Rn_A093zUZ0uPm-JYKrlVk',
    appId: '1:67992158660:web:dc929e22f06d5e1e3c6491',
    messagingSenderId: '67992158660',
    projectId: 'unifocus-app',
    authDomain: 'unifocus-app.firebaseapp.com',
    storageBucket: 'unifocus-app.firebasestorage.app',
  );
}
