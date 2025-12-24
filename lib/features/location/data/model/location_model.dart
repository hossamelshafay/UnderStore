class LocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final String? street;
  final String? locality;
  final String? administrativeArea;
  final String? country;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.street,
    this.locality,
    this.administrativeArea,
    this.country,
  });

  // Create from JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      address: json['address'] ?? '',
      street: json['street'],
      locality: json['locality'],
      administrativeArea: json['administrativeArea'],
      country: json['country'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'street': street,
      'locality': locality,
      'administrativeArea': administrativeArea,
      'country': country,
    };
  }

  // Copy with method
  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? street,
    String? locality,
    String? administrativeArea,
    String? country,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      street: street ?? this.street,
      locality: locality ?? this.locality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      country: country ?? this.country,
    );
  }

  @override
  String toString() {
    return 'LocationModel(latitude: $latitude, longitude: $longitude, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationModel &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode ^ address.hashCode;
  }
}
