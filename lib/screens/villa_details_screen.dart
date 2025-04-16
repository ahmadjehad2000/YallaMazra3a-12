import 'package:flutter/material.dart';
import '../models/villa.dart';

class VillaDetailsScreen extends StatelessWidget {
  final Villa villa;

  const VillaDetailsScreen({super.key, required this.villa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(villa.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                villa.imageUrl,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              villa.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 6),
                Text(villa.location, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${villa.price.toStringAsFixed(0)} دينار أردني / اليوم',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              villa.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildFeature('مسبح', villa.hasPool),
                _buildFeature('واي فاي', villa.hasWifi),
                _buildFeature('شواء', villa.hasBarbecue),
                _buildFeature('سعة', '${villa.capacity} أشخاص'),
                _buildFeature('تقييم', '${villa.rating} ⭐'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String label, dynamic value) {
    return Chip(
      label: Text(
        value is bool
            ? (value ? 'يوجد $label' : 'لا يوجد $label')
            : '$label: $value',
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
