import 'package:flutter/material.dart';

class LocationScreenHeader extends StatelessWidget {
  const LocationScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SizedBox(height: 20),
        Text(
          'Set Your Location',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Select your location to help us serve you better',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}
