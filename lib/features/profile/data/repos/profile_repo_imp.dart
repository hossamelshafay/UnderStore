import 'package:understore/features/auth/data/models/user.dart';
import 'package:understore/features/profile/data/repos/profile_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepoImp implements ProfileRepo {
  final auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;

  ProfileRepoImp(this._prefs)
    : _auth = auth.FirebaseAuth.instance,
      _firestore = FirebaseFirestore.instance;

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          return User(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            firstName: data['firstName'],
            lastName: data['lastName'],
            name: firebaseUser.displayName,
            location: data['location'],
            photoUrl: firebaseUser.photoURL,
            createdAt: firebaseUser.metadata.creationTime,
            lastLoginAt: firebaseUser.metadata.lastSignInTime,
            isEmailVerified: firebaseUser.emailVerified,
          );
        }
      } catch (firestoreError) {
        print('Firestore access failed: $firestoreError');
      }

      return User.fromFirebaseUser(firebaseUser);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  @override
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        throw Exception('No user logged in');
      }

      await firebaseUser.updateDisplayName('$firstName $lastName');

      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': firebaseUser.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> updateUserLocation(String location) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        throw Exception('No user logged in');
      }

      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'location': location,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        throw Exception('No user logged in');
      }

      // Reauthenticate user
      final credential = auth.EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: currentPassword,
      );

      await firebaseUser.reauthenticateWithCredential(credential);

      // Change password
      await firebaseUser.updatePassword(newPassword);
    } catch (e) {
      if (e is auth.FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          throw Exception('Current password is incorrect');
        }
      }
      throw Exception('Failed to change password: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _prefs.clear();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
