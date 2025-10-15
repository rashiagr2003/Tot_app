import 'package:hive/hive.dart';

part 'dog_model.g.dart';

@HiveType(typeId: 0)
class DogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String breed; // breed group or category

  @HiveField(3)
  final String? imageUrl; // ✅ renamed from "image" → "imageUrl"

  @HiveField(4)
  final String? breedGroup;

  @HiveField(5)
  final String? description; // temperament or other info

  @HiveField(6)
  final DateTime savedAt;

  DogModel({
    required this.id,
    required this.name,
    required this.breed,
    this.imageUrl,
    this.breedGroup,
    this.description,
    required this.savedAt,
  });

  /// ✅ Factory constructor that maps The Dog API structure
  factory DogModel.fromJson(Map<String, dynamic> json) {
    return DogModel(
      id: json['id'] ?? '',
      name: 'Unknown Dog',
      breed: 'N/A',
      imageUrl: json['url'] ?? '',
      breedGroup: 'N/A',
      description: 'No description available',
      savedAt: DateTime.now(),
    );
  }

  /// Convert to JSON (useful for debugging or Hive)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'imageUrl': imageUrl,
      'breed_group': breedGroup,
      'description': description,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}
