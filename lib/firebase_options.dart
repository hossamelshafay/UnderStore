import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'secret-api-key',  /// i deleted the real one for security reasons
    appId: '1:560808025375:android:7e6c267f5e7973f8a1642a',
    messagingSenderId: '560808025375',
    projectId: 'understore-1',
    storageBucket: 'understore-1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'secret-api-key',  /// i deleted the real one for security reasons
    appId: '1:560808025375:ios:72b37797d13a79b3a1642a',
    messagingSenderId: '560808025375',
    projectId: 'understore-1',
    storageBucket: 'understore-1.firebasestorage.app',
    iosClientId:
        '560808025375-tvqubs2vbg1nl3pgtvda54mvm75hcmqo.apps.googleusercontent.com',
    iosBundleId: 'com.example.cartsApp',
  );
}
