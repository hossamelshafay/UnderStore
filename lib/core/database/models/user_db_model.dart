class UserDbModel {
  final int? id;
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final String? location;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  UserDbModel({
    this.id,
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    this.location,
    this.latitude = 0.0,
    this.longitude = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory UserDbModel.fromMap(Map<String, dynamic> map) {
    return UserDbModel(
      id: map['id'] as int?,
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      location: map['location'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Copy with method
  UserDbModel copyWith({
    int? id,
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return UserDbModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserDbModel(id: $id, uid: $uid, email: $email, name: $name, phone: $phone, location: $location)';
  }
}
