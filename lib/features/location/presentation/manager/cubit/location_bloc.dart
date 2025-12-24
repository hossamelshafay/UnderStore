import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../data/model/location_model.dart';
import '../../../data/repos/location_repo.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepo locationRepo;

  LocationBloc(this.locationRepo) : super(LocationInitial()) {
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<SelectLocationEvent>(_onSelectLocation);
    on<SaveLocationEvent>(_onSaveLocation);
    on<LoadSavedLocationEvent>(_onLoadSavedLocation);
    on<GetAddressFromCoordinatesEvent>(_onGetAddressFromCoordinates);
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final result = await locationRepo.getCurrentLocation();

    result.fold((error) {
      if (error.contains('permission')) {
        emit(LocationPermissionDenied(error));
      } else {
        emit(LocationError(error));
      }
    }, (location) => emit(LocationLoaded(location)));
  }

  Future<void> _onSelectLocation(
    SelectLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final result = await locationRepo.getAddressFromCoordinates(
      event.latitude,
      event.longitude,
    );

    result.fold(
      (error) => emit(LocationError(error)),
      (address) => emit(
        AddressFetched(
          address: address,
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      ),
    );
  }

  Future<void> _onSaveLocation(
    SaveLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final result = await locationRepo.saveLocation(event.location);

    result.fold(
      (error) => emit(LocationError(error)),
      (_) => emit(LocationSaved('Location saved successfully')),
    );
  }

  Future<void> _onLoadSavedLocation(
    LoadSavedLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final result = await locationRepo.getSavedLocation();

    result.fold((error) => emit(LocationError(error)), (location) {
      if (location != null) {
        emit(LocationLoaded(location));
      } else {
        emit(LocationInitial());
      }
    });
  }

  Future<void> _onGetAddressFromCoordinates(
    GetAddressFromCoordinatesEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final result = await locationRepo.getAddressFromCoordinates(
      event.latitude,
      event.longitude,
    );

    result.fold(
      (error) => emit(LocationError(error)),
      (address) => emit(
        AddressFetched(
          address: address,
          latitude: event.latitude,
          longitude: event.longitude,
        ),
      ),
    );
  }
}
