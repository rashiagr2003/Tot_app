import 'package:hive/hive.dart';

part 'journey_model.g.dart';

@HiveType(typeId: 1)
class LocationPoint {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? address; // new optional field

  LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.address,
  });

  /// ✅ copyWith method
  LocationPoint copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? address,
  }) {
    return LocationPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
    );
  }
}

@HiveType(typeId: 2)
class JourneyModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final LocationPoint source;

  @HiveField(2)
  final LocationPoint destination;

  @HiveField(3)
  final List<LocationPoint> path;

  @HiveField(4)
  final DateTime startTime;

  @HiveField(5)
  final DateTime endTime;

  @HiveField(6)
  final double distance; // in kilometers

  JourneyModel({
    required this.id,
    required this.source,
    required this.destination,
    required this.path,
    required this.startTime,
    required this.endTime,
    required this.distance,
  });

  /// ✅ copyWith method
  JourneyModel copyWith({
    String? id,
    LocationPoint? source,
    LocationPoint? destination,
    List<LocationPoint>? path,
    DateTime? startTime,
    DateTime? endTime,
    double? distance,
  }) {
    return JourneyModel(
      id: id ?? this.id,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      path: path ?? this.path,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distance: distance ?? this.distance,
    );
  }

  Duration get duration => endTime.difference(startTime);
}
