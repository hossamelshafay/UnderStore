import 'package:understore/features/auth/data/models/user.dart';

abstract class ProfileRepo {
  Future<User?> getCurrentUser();
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
  });
  Future<void> updateUserLocation(String location);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> signOut();
}
