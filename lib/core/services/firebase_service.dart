import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._internal();

  FirebaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized && Firebase.apps.isNotEmpty;

  FirebaseAuth? get auth => isInitialized ? FirebaseAuth.instance : null;
  FirebaseFirestore? get firestore => isInitialized ? FirebaseFirestore.instance : null;
  FirebaseStorage? get storage => isInitialized ? FirebaseStorage.instance : null;

  Future<bool> init() async {
    if (_isInitialized && Firebase.apps.isNotEmpty) return true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      if (Firebase.apps.isNotEmpty) {
        final firestoreInstance = FirebaseFirestore.instance;
        if (!kIsWeb) {
          firestoreInstance.settings = const Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
        }
        _isInitialized = true;
        debugPrint('[FirebaseService] Successfully initialized Firebase backend.');
        return true;
      }
      return false;
    } catch (e, stack) {
      debugPrint('[FirebaseService] Firebase initialization notice (running offline/local mode): $e\n$stack');
      _isInitialized = false;
      return false;
    }
  }
}
