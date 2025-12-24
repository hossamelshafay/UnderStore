part of 'location_bloc.dart';

@immutable
sealed class LocationEvent {}

///  to get current location
final class GetCurrentLocationEvent extends LocationEvent {}

/// to select location from map
final class SelectLocationEvent extends LocationEvent {
  final double latitude;
  final double longitude;

  SelectLocationEvent({required this.latitude, required this.longitude});
}

///  to save selected location
final class SaveLocationEvent extends LocationEvent {
  final LocationModel location;

  SaveLocationEvent(this.location);
}

///  to load saved location
final class LoadSavedLocationEvent extends LocationEvent {}

///  to get address from coordinates
final class GetAddressFromCoordinatesEvent extends LocationEvent {
  final double latitude;
  final double longitude;

  GetAddressFromCoordinatesEvent({
    required this.latitude,
    required this.longitude,
  });
}
