import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCG15DlDezWGPlG2wie5BVJzOdglUoOaCY',
    appId: '1:523129926138:web:fde1c5f4acea934bddb443',
    messagingSenderId: '523129926138',
    projectId: 'tamanna-fa1aa',
    authDomain: 'tamanna-fa1aa.firebaseapp.com',
    storageBucket: 'tamanna-fa1aa.firebasestorage.app',
    measurementId: 'G-W4EGS5NJHM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1HeEZ-Y5M4M-rh5Osf-gvaaR2aTqc0Eg',
    appId: '1:523129926138:android:1bbe2a763e09fae4ddb443',
    messagingSenderId: '523129926138',
    projectId: 'tamanna-fa1aa',
    storageBucket: 'tamanna-fa1aa.firebasestorage.app',
  );
}
