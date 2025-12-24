// import 'package:flutter/foundation.dart';

abstract class AuthRepo {
  Future<void> signIn({required String email, required String password});

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> resetPassword({required String email});

  // Future<void> signOut();

  Future<bool> isSignedIn();
}
