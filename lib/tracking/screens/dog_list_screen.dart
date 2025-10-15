import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tot_app/adapters/providers/dog_provider.dart';
import 'package:tot_app/tracking/screens/dog_details_screen.dart';

class DogListScreen extends StatefulWidget {
  const DogListScreen({Key? key}) : super(key: key);

  @override
  State<DogListScreen> createState() => _DogListScreenState();
}

class _DogListScreenState extends State<DogListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // ✅ Call fetchDogs when the screen first opens
    Future.microtask(() {
      Provider.of<DogProvider>(context, listen: false).fetchDogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DogProvider>(
      builder: (context, dogProvider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  dogProvider.searchDogs(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search dogs by name or breed...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            dogProvider.searchDogs('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: dogProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dogProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dogProvider.error!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => dogProvider.fetchDogs(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: dogProvider.dogs.length,
                      itemBuilder: (context, index) {
                        final dog = dogProvider.dogs[index];
                        final isSaved = dogProvider.isSaved(dog.id);
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: dog.imageUrl != null
                                ? Image.network(
                                    dog.imageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.pets),
                                  )
                                : const Icon(Icons.pets, size: 40),
                            title: Text(
                              dog.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(dog.breed),
                            trailing: IconButton(
                              icon: Icon(
                                isSaved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isSaved ? Colors.red : null,
                              ),
                              onPressed: () {
                                if (isSaved) {
                                  dogProvider.removeDog(dog.id);
                                } else {
                                  dogProvider.saveDog(dog);
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DogDetailScreen(dog: dog),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
