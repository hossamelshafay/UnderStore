import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/user_db_model.dart';

class UserDatabaseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Insert or update user
  Future<int> saveUser(UserDbModel user) async {
    final db = await _dbHelper.database;

    // Try to insert, if conflict (uid exists), update instead
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get user by UID
  Future<UserDbModel?> getUserByUid(String uid) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserDbModel.fromMap(maps.first);
  }

  // Update user details
  Future<int> updateUser(UserDbModel user) async {
    final db = await _dbHelper.database;

    return await db.update(
      'users',
      user.toMap(),
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  // Update user phone
  Future<int> updatePhone(String uid, String phone) async {
    final db = await _dbHelper.database;

    return await db.update(
      'users',
      {'phone': phone},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // Update user location
  Future<int> updateLocation(
    String uid,
    String location,
    double latitude,
    double longitude,
  ) async {
    final db = await _dbHelper.database;

    return await db.update(
      'users',
      {'location': location, 'latitude': latitude, 'longitude': longitude},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  // Delete user
  Future<int> deleteUser(String uid) async {
    final db = await _dbHelper.database;

    return await db.delete('users', where: 'uid = ?', whereArgs: [uid]);
  }

  // Get all users (for admin purposes)
  Future<List<UserDbModel>> getAllUsers() async {
    final db = await _dbHelper.database;

    final maps = await db.query('users', orderBy: 'createdAt DESC');
    return maps.map((map) => UserDbModel.fromMap(map)).toList();
  }

  // Check if user exists
  Future<bool> userExists(String uid) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}
