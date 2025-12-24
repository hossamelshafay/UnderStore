class User {
  final String uid;
  final String email;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? location;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;

  const User({
    required this.uid,
    required this.email,
    this.name,
    this.firstName,
    this.lastName,
    this.location,
    this.photoUrl,
    this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
  });

  // Create User from Firebase User
  factory User.fromFirebaseUser(dynamic firebaseUser) {
    final displayName = firebaseUser.displayName;
    String? firstName;
    String? lastName;
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(' ');
      firstName = parts.isNotEmpty ? parts[0] : null;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
    }

    return User(
      uid: firebaseUser.uid ?? '',
      email: firebaseUser.email ?? '',
      name: displayName,
      firstName: firstName,
      lastName: lastName,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata?.creationTime,
      lastLoginAt: firebaseUser.metadata?.lastSignInTime,
      isEmailVerified: firebaseUser.emailVerified ?? false,
    );
  }

  // Create User JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      location: json['location'],
      photoUrl: json['photoUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'location': location,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? name,
    String? firstName,
    String? lastName,
    String? location,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  String get displayName {
    if (firstName?.isNotEmpty == true && lastName?.isNotEmpty == true) {
      return '$firstName $lastName';
    } else if (firstName?.isNotEmpty == true) {
      return firstName!;
    } else if (name?.isNotEmpty == true) {
      return name!;
    }
    return email;
  }

  // Get First letter for avatar
  String get initials {
    if (firstName?.isNotEmpty == true) {
      return firstName![0].toUpperCase();
    } else if (name?.isNotEmpty == true) {
      return name![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.location == location &&
        other.photoUrl == photoUrl &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.isEmailVerified == isEmailVerified;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        name.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        location.hashCode ^
        photoUrl.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode ^
        isEmailVerified.hashCode;
  }

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, name: $name, firstName: $firstName, lastName: $lastName, location: $location, photoUrl: $photoUrl, createdAt: $createdAt, lastLoginAt: $lastLoginAt, isEmailVerified: $isEmailVerified)';
  }
}
