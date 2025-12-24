import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:understore/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:understore/features/location/presentation/widgets/location_picker_page.dart';
import 'package:understore/features/location/presentation/manager/cubit/location_bloc.dart';
import 'package:understore/features/location/data/repos/location_repo_imp.dart';
import 'package:understore/features/location/data/model/location_model.dart';
import 'package:understore/features/home/presentation/views/home_screen.dart';
import 'package:understore/features/location/presentation/widgets/location_display_card.dart';
import 'package:understore/features/location/presentation/widgets/location_action_button.dart';
import 'package:understore/features/location/presentation/widgets/location_save_button.dart';
import 'package:understore/features/location/presentation/widgets/location_screen_header.dart';

class LocationScreen extends StatelessWidget {
  final String currentLocation;
  final bool isFirstTime;

  const LocationScreen({
    super.key,
    required this.currentLocation,
    this.isFirstTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0E21),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5145FC)),
              ),
            ),
          );
        }

        return BlocProvider(
          create: (context) =>
              LocationBloc(LocationRepoImp(snapshot.data!))
                ..add(LoadSavedLocationEvent()),
          child: _LocationScreenContent(
            currentLocation: currentLocation,
            isFirstTime: isFirstTime,
          ),
        );
      },
    );
  }
}

class _LocationScreenContent extends StatefulWidget {
  final String currentLocation;
  final bool isFirstTime;

  const _LocationScreenContent({
    required this.currentLocation,
    required this.isFirstTime,
  });

  @override
  State<_LocationScreenContent> createState() => _LocationScreenContentState();
}

class _LocationScreenContentState extends State<_LocationScreenContent> {
  LocationModel? _selectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation.isNotEmpty) {
      _selectedLocation = LocationModel(
        latitude: 0.0,
        longitude: 0.0,
        address: widget.currentLocation,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E1A47),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5145FC).withOpacity(0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Location',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              if (state is LocationLoaded) {
                setState(() {
                  _selectedLocation = state.location;
                });
              } else if (state is LocationSaved) {
                // Update profile with location
                if (_selectedLocation != null) {
                  context.read<ProfileCubit>().updateLocation(
                    _selectedLocation!.address,
                  );
                }
              } else if (state is LocationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is LocationPermissionDenied) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
          BlocListener<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );

                // If first time setup, navigate to home screen
                if (widget.isFirstTime) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                } else {
                  Navigator.pop(context);
                }
              } else if (state is ProfileUpdateError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            final isLoading = state is LocationLoading;

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LocationScreenHeader(),
                      const SizedBox(height: 32),

                      // Selected location display
                      LocationDisplayCard(
                        selectedAddress: _selectedLocation?.address,
                      ),

                      const SizedBox(height: 20),

                      // Get Current Location button
                      LocationActionButton(
                        icon: Icons.my_location,
                        label: 'Get Current Location',
                        isLoading: isLoading,
                        onPressed: () => context.read<LocationBloc>().add(
                          GetCurrentLocationEvent(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Select from map button
                      LocationActionButton(
                        icon: Icons.map_outlined,
                        label: 'Select from Map',
                        onPressed: _openMapPicker,
                      ),

                      const Spacer(),

                      // Save button
                      LocationSaveButton(
                        isEnabled: _selectedLocation != null,
                        isLoading: isLoading,
                        label: widget.isFirstTime
                            ? 'Continue'
                            : 'Save Location',
                        onPressed: _saveLocation,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF5145FC),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openMapPicker() async {
    // Get the bloc before navigating
    final locationBloc = context.read<LocationBloc>();

    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: locationBloc,
          child: LocationPickerPage(initialLocation: _selectedLocation),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _saveLocation() {
    if (_selectedLocation == null ||
        _selectedLocation!.address.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location from the map'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save to location repo
    context.read<LocationBloc>().add(SaveLocationEvent(_selectedLocation!));
  }
}
