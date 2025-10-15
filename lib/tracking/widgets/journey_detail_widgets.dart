import 'package:flutter/material.dart';
import 'package:tot_app/models/journey_model.dart';

class JourneyDetailsWidget extends StatelessWidget {
  final JourneyModel journey;

  const JourneyDetailsWidget({Key? key, required this.journey})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journey Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Distance',
              '${journey.distance.toStringAsFixed(2)} km',
            ),
            _buildDetailRow(
              'Duration',
              '${journey.duration.inHours}h ${journey.duration.inMinutes % 60}m',
            ),
            _buildDetailRow('Start Time', journey.startTime.toString()),
            _buildDetailRow('End Time', journey.endTime.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
