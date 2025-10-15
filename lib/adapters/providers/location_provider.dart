import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'package:tot_app/models/journey_model.dart';
import 'package:tot_app/tracking/utils/distance_calculator.dart';

class LocationProvider extends ChangeNotifier {
  LocationPoint? _currentLocation;
  LocationPoint? _sourceLocation;
  LocationPoint? _destinationLocation;
  List<LocationPoint> _journeyPath = [];
  List<JourneyModel> _savedJourneys = [];
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStream;
  String? _error;
  double _totalDistance = 0;

  LocationPoint? get currentLocation => _currentLocation;
  LocationPoint? get sourceLocation => _sourceLocation;
  LocationPoint? get destinationLocation => _destinationLocation;
  List<LocationPoint> get journeyPath => _journeyPath;
  List<JourneyModel> get savedJourneys => _savedJourneys;
  bool get isTracking => _isTracking;
  String? get error => _error;
  double get totalDistance => _totalDistance;

  LocationProvider() {
    _loadSavedJourneys();
  }
  Future<String?> getAddressFromLatLng(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.name}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      print("Error in reverse geocoding: $e");
    }
    return null;
  }

  Future<void> startTracking() async {
    _error = null;
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _error = 'Location permission denied';
      notifyListeners();
      return;
    }

    _isTracking = true;
    _journeyPath.clear();
    _totalDistance = 0;

    final initialPosition = await Geolocator.getCurrentPosition();
    _sourceLocation = LocationPoint(
      latitude: initialPosition.latitude,
      longitude: initialPosition.longitude,
      timestamp: DateTime.now(),
    );
    _journeyPath.add(_sourceLocation!);

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          _currentLocation = LocationPoint(
            latitude: position.latitude,
            longitude: position.longitude,
            timestamp: DateTime.now(),
          );
          getAddressFromLatLng(position.latitude, position.longitude).then((
            address,
          ) {
            _currentLocation = _currentLocation!.copyWith(address: address);
            notifyListeners();
          });

          _journeyPath.add(_currentLocation!);

          if (_journeyPath.length > 1) {
            final distance = DistanceCalculator.calculateDistance(
              _journeyPath[_journeyPath.length - 2].latitude,
              _journeyPath[_journeyPath.length - 2].longitude,
              _currentLocation!.latitude,
              _currentLocation!.longitude,
            );
            _totalDistance += distance;
          }

          notifyListeners();
        });

    notifyListeners();
  }

  Future<void> stopTracking() async {
    if (_positionStream != null) {
      await _positionStream!.cancel();
    }

    if (_currentLocation != null) {
      _destinationLocation = _currentLocation;
      await _saveJourney();
    }

    _isTracking = false;
    notifyListeners();
  }

  Future<void> _saveJourney() async {
    if (_sourceLocation == null || _destinationLocation == null) return;

    final journey = JourneyModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      source: _sourceLocation!,
      destination: _destinationLocation!,
      path: _journeyPath,
      startTime: _sourceLocation!.timestamp,
      endTime: _destinationLocation!.timestamp,
      distance: _totalDistance,
    );

    final box = Hive.box<JourneyModel>('journeys');
    await box.put(journey.id, journey);
    _loadSavedJourneys();
  }

  void _loadSavedJourneys() {
    final box = Hive.box<JourneyModel>('journeys');
    _savedJourneys = box.values.toList();
    notifyListeners();
  }

  void clearCurrentTracking() {
    _currentLocation = null;
    _sourceLocation = null;
    _destinationLocation = null;
    _journeyPath.clear();
    _totalDistance = 0;
    _isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
