import 'package:dartz/dartz.dart';
import '../model/location_model.dart';

abstract class LocationRepo {
  Future<Either<String, LocationModel>> getCurrentLocation();

  Future<Either<String, String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  );

  /// Save location to local storage
  Future<Either<String, void>> saveLocation(LocationModel location);

  Future<Either<String, LocationModel?>> getSavedLocation();

  Future<bool> checkLocationPermission();

  Future<bool> requestLocationPermission();
}
