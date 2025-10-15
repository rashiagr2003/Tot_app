import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart'; // for reverse geocoding

import '../../adapters/providers/location_provider.dart';

class LocationTrackingScreen extends StatelessWidget {
  const LocationTrackingScreen({Key? key}) : super(key: key);

  Future<String> _getAddress(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Error fetching address';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Location Tracking',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (locationProvider.isTracking) ...[
                          _buildLocationInfo(
                            'Current Location',
                            locationProvider.currentLocation,
                          ),
                          const SizedBox(height: 12),
                          _buildLocationInfo(
                            'Source Location',
                            locationProvider.sourceLocation,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Distance Traveled: ${locationProvider.totalDistance.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ] else if (locationProvider.destinationLocation !=
                            null) ...[
                          _buildLocationInfo(
                            'Source',
                            locationProvider.sourceLocation,
                          ),
                          const SizedBox(height: 12),
                          _buildLocationInfo(
                            'Destination',
                            locationProvider.destinationLocation,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Total Distance: ${locationProvider.totalDistance.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ] else
                          const Text(
                            'Press Start to begin tracking your journey',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                      onPressed: locationProvider.isTracking
                          ? null
                          : () {
                              locationProvider.startTracking();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      onPressed: !locationProvider.isTracking
                          ? null
                          : () {
                              locationProvider.stopTracking();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      onPressed:
                          !locationProvider.isTracking &&
                              locationProvider.sourceLocation == null
                          ? null
                          : () {
                              locationProvider.clearCurrentTracking();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationInfo(String label, dynamic location) {
    if (location == null) {
      return Text('$label: Not captured yet');
    }

    return FutureBuilder<String>(
      future: location.address != null
          ? Future.value(location.address) // if already stored
          : _getAddress(location.latitude, location.longitude),
      builder: (context, snapshot) {
        String display = snapshot.connectionState == ConnectionState.done
            ? snapshot.data ?? 'Unknown'
            : 'Fetching address...';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              display,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Lat: ${location.latitude.toStringAsFixed(4)}, Lon: ${location.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}
