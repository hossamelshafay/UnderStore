import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repo.dart';

class AuthRepoImp implements AuthRepo {
  final FirebaseAuth _auth;
  final SharedPreferences _prefs;

  AuthRepoImp(this._prefs) : _auth = FirebaseAuth.instance;

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    if (!email.contains('@')) {
      throw Exception('Please enter a valid email address');
    }
    final userCredential = await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .timeout(const Duration(seconds: 30));
    if (userCredential.user == null) {
      throw Exception('Failed to get user details');
    }
    await _prefs.setString('uid', userCredential.user!.uid);
    await _prefs.setBool('isLoggedIn', true);
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) {
      throw Exception('Failed to create user');
    }

    await userCredential.user!.updateDisplayName(name);

    final nameParts = name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : name;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

    await _prefs.setString('uid', userCredential.user!.uid);
    await _prefs.setBool('isLoggedIn', true);
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  // Future<void> signOut() async {
  //   await _auth.signOut();
  //   await _prefs.clear();
  // }
  @override
  Future<bool> isSignedIn() async {
    return _prefs.getBool('isLoggedIn') ?? false;
  }
}
