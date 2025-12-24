part of 'location_bloc.dart';

@immutable
sealed class LocationState {}

final class LocationInitial extends LocationState {}

final class LocationLoading extends LocationState {}

final class LocationLoaded extends LocationState {
  final LocationModel location;

  LocationLoaded(this.location);
}

/// Success state when location is saved
final class LocationSaved extends LocationState {
  final String message;

  LocationSaved(this.message);
}

/// Success state when address is fetched
final class AddressFetched extends LocationState {
  final String address;
  final double latitude;
  final double longitude;

  AddressFetched({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

final class LocationError extends LocationState {
  final String message;

  LocationError(this.message);
}

final class LocationPermissionDenied extends LocationState {
  final String message;

  LocationPermissionDenied(this.message);
}
