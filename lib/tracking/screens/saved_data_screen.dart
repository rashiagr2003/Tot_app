import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tot_app/adapters/providers/dog_provider.dart';

import '../../adapters/providers/location_provider.dart';
import 'dog_details_screen.dart';

class SavedDataScreen extends StatefulWidget {
  const SavedDataScreen({Key? key}) : super(key: key);

  @override
  State<SavedDataScreen> createState() => _SavedDataScreenState();
}

class _SavedDataScreenState extends State<SavedDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Data'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dogs'),
            Tab(text: 'Journeys'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSavedDogsTab(), _buildSavedJourneysTab()],
      ),
    );
  }

  Widget _buildSavedDogsTab() {
    return Consumer<DogProvider>(
      builder: (context, dogProvider, _) {
        if (dogProvider.savedDogs.isEmpty) {
          return const Center(child: Text('No saved dogs yet'));
        }
        return ListView.builder(
          itemCount: dogProvider.savedDogs.length,
          itemBuilder: (context, index) {
            final dog = dogProvider.savedDogs[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: dog.imageUrl != null
                    ? Image.network(
                        dog.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.pets),
                      )
                    : const Icon(Icons.pets, size: 40),
                title: Text(
                  dog.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(dog.breed),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    dogProvider.removeDog(dog.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dog removed from saved')),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DogDetailScreen(dog: dog),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSavedJourneysTab() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        if (locationProvider.savedJourneys.isEmpty) {
          return const Center(child: Text('No saved journeys yet'));
        }
        return ListView.builder(
          itemCount: locationProvider.savedJourneys.length,
          itemBuilder: (context, index) {
            final journey = locationProvider.savedJourneys[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ExpansionTile(
                title: Text(
                  'Journey ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Distance: ${journey.distance.toStringAsFixed(2)} km',
                  style: const TextStyle(color: Colors.blue),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildJourneyInfo(
                          'Start Time',
                          journey.startTime.toString(),
                        ),
                        const SizedBox(height: 12),
                        _buildJourneyInfo(
                          'End Time',
                          journey.endTime.toString(),
                        ),
                        const SizedBox(height: 12),
                        _buildJourneyInfo(
                          'Duration',
                          '${journey.duration.inHours}h ${journey.duration.inMinutes % 60}m',
                        ),
                        const SizedBox(height: 12),
                        _buildJourneyInfo(
                          'Source',
                          'Lat: ${journey.source.latitude.toStringAsFixed(4)}, Lon: ${journey.source.longitude.toStringAsFixed(4)}',
                        ),
                        const SizedBox(height: 12),
                        _buildJourneyInfo(
                          'Destination',
                          'Lat: ${journey.destination.latitude.toStringAsFixed(4)}, Lon: ${journey.destination.longitude.toStringAsFixed(4)}',
                        ),
                        const SizedBox(height: 12),
                        _buildJourneyInfo(
                          'Total Distance',
                          '${journey.distance.toStringAsFixed(2)} km',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJourneyInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(value, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
