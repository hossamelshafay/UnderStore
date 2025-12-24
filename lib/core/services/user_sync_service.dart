import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/repositories/user_db_repository.dart';
import '../database/models/user_db_model.dart';
import '../../features/location/data/model/location_model.dart';

class UserSyncService {
  final UserDatabaseRepository _userDbRepo = UserDatabaseRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sync user from Firebase to SQLite
  Future<void> syncUserToLocal() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get user data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) return;

      final data = doc.data()!;

      // Save to SQLite
      final userDb = UserDbModel(
        uid: user.uid,
        email: user.email ?? data['email'] ?? '',
        name: data['name'] ?? user.displayName ?? '',
        phone: data['phone'],
        location: data['location'],
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      );

      await _userDbRepo.saveUser(userDb);
    } catch (e) {
      print('Error syncing user to local: $e');
    }
  }

  // Get user from SQLite (faster than Firebase)
  Future<UserDbModel?> getLocalUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return await _userDbRepo.getUserByUid(user.uid);
  }

  // Update phone in both SQLite and Firebase
  Future<void> updatePhone(String phone) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Update in SQLite
    await _userDbRepo.updatePhone(user.uid, phone);

    // Update in Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update location in both SQLite and Firebase
  Future<void> updateLocation(LocationModel location) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Update in SQLite
    await _userDbRepo.updateLocation(
      user.uid,
      location.address,
      location.latitude,
      location.longitude,
    );

    // Update in Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'location': location.address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{};

    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (location != null) updates['location'] = location;
    if (latitude != null) updates['latitude'] = latitude;
    if (longitude != null) updates['longitude'] = longitude;
    updates['updatedAt'] = FieldValue.serverTimestamp();

    // Update in Firestore
    await _firestore.collection('users').doc(user.uid).update(updates);

    // Update in SQLite
    final currentUser = await _userDbRepo.getUserByUid(user.uid);
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        phone: phone ?? currentUser.phone,
        location: location ?? currentUser.location,
        latitude: latitude ?? currentUser.latitude,
        longitude: longitude ?? currentUser.longitude,
      );
      await _userDbRepo.updateUser(updatedUser);
    }
  }

  // Clear local data on logout
  Future<void> clearLocalData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _userDbRepo.deleteUser(user.uid);
    }
  }
}
