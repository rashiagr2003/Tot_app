import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:tot_app/models/dog_model.dart';

class DogProvider with ChangeNotifier {
  final String _baseUrl =
      'https://api.thedogapi.com/v1/images/search?limit=20&has_breeds=1';
  final String _apiKey = 'YOUR_API_KEY_HERE'; // Replace with your API key

  List<DogModel> _dogs = [];
  List<DogModel> _filteredDogs = [];
  List<DogModel> _savedDogs = [];

  bool _isLoading = false;
  String? _error;

  List<DogModel> get dogs => _filteredDogs.isNotEmpty ? _filteredDogs : _dogs;
  List<DogModel> get savedDogs => _savedDogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// ✅ Fetch Dogs from API
  Future<void> fetchDogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://api.thedogapi.com/v1/images/search?limit=10'),
        headers: {'x-api-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print(response.body);

        _dogs = jsonData.map((dog) {
          return DogModel(
            id: dog['id'] ?? '',
            name: 'Random Dog',
            breed: 'Unknown',
            imageUrl: dog['url'] ?? '',
            breedGroup: null,
            description: null,
            savedAt: DateTime.now(),
          );
        }).toList();
      } else {
        _error = 'Failed to load dogs: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔍 Search Dogs by name or breed
  void searchDogs(String query) {
    if (query.isEmpty) {
      _filteredDogs = [];
    } else {
      _filteredDogs = _dogs
          .where(
            (dog) =>
                dog.name.toLowerCase().contains(query.toLowerCase()) ||
                dog.breed.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  /// ❤️ Save a Dog to Hive
  Future<void> saveDog(DogModel dog) async {
    final box = Hive.box<DogModel>('dogs');
    await box.put(dog.id, dog);
    _loadSavedDogs();
  }

  /// ❌ Remove Dog from saved list
  Future<void> removeDog(String id) async {
    final box = Hive.box<DogModel>('dogs');
    await box.delete(id);
    _loadSavedDogs();
  }

  /// 🔁 Load saved dogs from Hive
  void _loadSavedDogs() {
    final box = Hive.box<DogModel>('dogs');
    _savedDogs = box.values.toList();
    notifyListeners();
  }

  /// ✅ Check if dog is saved
  bool isSaved(String id) {
    final box = Hive.box<DogModel>('dogs');
    return box.containsKey(id);
  }
}
