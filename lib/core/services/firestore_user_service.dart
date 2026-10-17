import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/semester.dart';
import '../models/study_session.dart';
import '../models/user_profile.dart';
import '../models/user_settings.dart';
import 'firebase_service.dart';

class FirestoreUserService {
  final FirebaseService _firebaseService;

  FirestoreUserService([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  FirebaseFirestore? get _firestore => _firebaseService.firestore;
  bool get _isAvailable => _firebaseService.isInitialized && _firestore != null;

  // ---------------------------------------------------------------------------
  // Profile: users/{uid}
  // ---------------------------------------------------------------------------
  Future<UserProfile?> fetchUserProfile(String uid) async {
    if (!_isAvailable) return null;
    try {
      final doc = await _firestore!.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('[FirestoreUserService] fetchUserProfile error: $e');
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    if (!_isAvailable) return;
    if (profile.id.isEmpty ||
        profile.id == 'user_initial' ||
        profile.id == 'clean_user' ||
        profile.id == 'demo_user') {
      return;
    }
    try {
      final data = profile.toJson();
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore!.collection('users').doc(profile.id).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirestoreUserService] saveUserProfile error: $e');
    }
  }

  Stream<UserProfile?> streamUserProfile(String uid) {
    if (!_isAvailable) return const Stream.empty();
    return _firestore!.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserProfile.fromJson(snapshot.data()!);
    });
  }

  // ---------------------------------------------------------------------------
  // Settings: users/{uid}/settings
  // ---------------------------------------------------------------------------
  Future<UserSettings> fetchUserSettings(String uid) async {
    if (!_isAvailable) return const UserSettings();
    try {
      final doc = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('user_preferences')
          .get();
      if (!doc.exists || doc.data() == null) return const UserSettings();
      return UserSettings.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('[FirestoreUserService] fetchUserSettings error: $e');
      return const UserSettings();
    }
  }

  Future<void> saveUserSettings(String uid, UserSettings settings) async {
    if (!_isAvailable) return;
    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('user_preferences')
          .set(settings.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirestoreUserService] saveUserSettings error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Semesters & Courses: users/{uid}/semesters/{semesterId}/courses/{courseId}
  // ---------------------------------------------------------------------------
  Future<List<Semester>> fetchUserSemesters(String uid) async {
    if (!_isAvailable) return const [];
    try {
      final semSnapshot = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('semesters')
          .get();

      final semesters = <Semester>[];

      for (final doc in semSnapshot.docs) {
        final semData = doc.data();
        final semesterId = doc.id;

        final coursesSnapshot = await doc.reference.collection('courses').get();
        final courses = coursesSnapshot.docs.map((cDoc) {
          final cData = cDoc.data();
          cData['id'] = cDoc.id;
          cData['semesterId'] = semesterId;
          return Course.fromJson(cData);
        }).toList();

        semData['id'] = semesterId;
        final semester = Semester.fromJson(semData).copyWith(courses: courses);
        semesters.add(semester);
      }

      return semesters;
    } catch (e) {
      debugPrint('[FirestoreUserService] fetchUserSemesters error: $e');
      return const [];
    }
  }

  Future<void> saveSemester(String uid, Semester semester) async {
    if (!_isAvailable) return;
    try {
      final semRef = _firestore!
          .collection('users')
          .doc(uid)
          .collection('semesters')
          .doc(semester.id);

      final semMap = semester.toJson();
      semMap.remove('courses');
      await semRef.set(semMap, SetOptions(merge: true));

      final batch = _firestore!.batch();
      for (final course in semester.courses) {
        final courseRef = semRef.collection('courses').doc(course.id);
        batch.set(courseRef, course.toJson(), SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[FirestoreUserService] saveSemester error: $e');
    }
  }

  Future<void> deleteSemester(String uid, String semesterId) async {
    if (!_isAvailable) return;
    try {
      final semRef = _firestore!
          .collection('users')
          .doc(uid)
          .collection('semesters')
          .doc(semesterId);

      final courses = await semRef.collection('courses').get();
      final batch = _firestore!.batch();
      for (final c in courses.docs) {
        batch.delete(c.reference);
      }
      batch.delete(semRef);
      await batch.commit();
    } catch (e) {
      debugPrint('[FirestoreUserService] deleteSemester error: $e');
    }
  }

  Future<void> saveCourse(String uid, String semesterId, Course course) async {
    if (!_isAvailable) return;
    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('semesters')
          .doc(semesterId)
          .collection('courses')
          .doc(course.id)
          .set(course.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirestoreUserService] saveCourse error: $e');
    }
  }

  Future<void> deleteCourse(String uid, String semesterId, String courseId) async {
    if (!_isAvailable) return;
    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('semesters')
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .delete();
    } catch (e) {
      debugPrint('[FirestoreUserService] deleteCourse error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Sessions: users/{uid}/sessions/{sessionId}
  // ---------------------------------------------------------------------------
  Future<void> saveSessionSummary(String uid, StudySession session) async {
    if (!_isAvailable) return;
    try {
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .doc(session.id)
          .set(session.toJson());
    } catch (e) {
      debugPrint('[FirestoreUserService] saveSessionSummary error: $e');
    }
  }

  Future<List<StudySession>> fetchSessionHistory(String uid) async {
    if (!_isAvailable) return const [];
    try {
      final snapshot = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => StudySession.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('[FirestoreUserService] fetchSessionHistory error: $e');
      return const [];
    }
  }
}
