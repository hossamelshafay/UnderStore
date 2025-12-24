import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/location_model.dart';
import 'location_repo.dart';

class LocationRepoImp implements LocationRepo {
  final SharedPreferences sharedPreferences;
  static const String _locationKey = 'saved_location';

  LocationRepoImp(this.sharedPreferences);

  @override
  Future<Either<String, LocationModel>> getCurrentLocation() async {
    try {
      // Check permission
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        final granted = await requestLocationPermission();
        if (!granted) {
          return const Left('Location permission denied');
        }
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Get address
      final addressResult = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = '';
      addressResult.fold(
        (error) => address =
            'Lat: ${position.latitude.toStringAsFixed(4)}, '
            'Lng: ${position.longitude.toStringAsFixed(4)}',
        (addr) => address = addr,
      );

      final location = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      return Right(location);
    } catch (e) {
      return Left('Failed to get current location: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return const Left('No address found for these coordinates');
      }

      final place = placemarks[0];
      final address = [
        place.street,
        place.locality,
        place.administrativeArea,
        place.country,
      ].where((e) => e != null && e.isNotEmpty).join(', ');

      if (address.isEmpty) {
        return Left(
          'Lat: ${latitude.toStringAsFixed(4)}, '
          'Lng: ${longitude.toStringAsFixed(4)}',
        );
      }

      return Right(address);
    } catch (e) {
      return Left('Failed to get address: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> saveLocation(LocationModel location) async {
    try {
      final jsonString = jsonEncode(location.toJson());
      await sharedPreferences.setString(_locationKey, jsonString);
      return const Right(null);
    } catch (e) {
      return Left('Failed to save location: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, LocationModel?>> getSavedLocation() async {
    try {
      final jsonString = sharedPreferences.getString(_locationKey);
      if (jsonString == null) {
        return const Right(null);
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final location = LocationModel.fromJson(json);
      return Right(location);
    } catch (e) {
      return Left('Failed to get saved location: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }
}
