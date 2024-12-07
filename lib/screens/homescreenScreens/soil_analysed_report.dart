import 'dart:ui';

import 'package:flutter/material.dart';

class SoilDataAnalyzed extends StatefulWidget {
  @override
  _SoilDataAnalyzedState createState() => _SoilDataAnalyzedState();
}

class _SoilDataAnalyzedState extends State<SoilDataAnalyzed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Analysis', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Analysis Card
            _buildCurrentAnalysisCard(),

            const SizedBox(height: 16),

            // Soil Type Card
            _buildSoilTypeCard(),

            const SizedBox(height: 16),

            // Best Crops to Grow
            _buildBestCropsToGrow(),

            const SizedBox(height: 16),

            // Custom Crop Selection
            _buildCustomCropSelection(),

            const SizedBox(height: 16),

            // Recent Samples
            _buildRecentSamples(),

            const SizedBox(height: 16),

            // Recommendations
            _buildRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAnalysisCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 32, color: Colors.black),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Current Analysis',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text('Field Section A-23', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatTile('pH Level', '6.8'),
                _buildStatTile('Moisture', '42%'),
              ],
            ),
            const SizedBox(height: 16),
            _buildNutrientBar('Nitrogen (N)', 0.75),
            _buildNutrientBar('Phosphorus (P)', 0.60),
            _buildNutrientBar('Potassium (K)', 0.85),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNutrientBar(String title, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          color: Colors.black,
          backgroundColor: Colors.grey[300],
          minHeight: 8,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSoilTypeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.terrain, size: 32, color: Colors.black),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Soil Type', style: TextStyle(color: Colors.grey)),
                Text('Clay Loam', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestCropsToGrow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Best Crops to Grow',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildCropCard('Wheat', 'High success rate'),
            _buildCropCard('Corn', 'Good compatibility'),
            _buildCropCard('Soybean', 'Optimal conditions'),
            _buildCropCard('Barley', 'Suitable pH level'),
          ],
        ),
      ],
    );
  }

  Widget _buildCropCard(String title, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: double.infinity,
              color: Colors.grey[300], // Placeholder for image
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCropSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Custom Crop Selection',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for crops...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildChip('Rice'),
                _buildChip('Cotton'),
                _buildChip('Sugarcane'),
                _buildChip('+ Add Custom', isAddCustom: true),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('Analyze Compatibility'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, {bool isAddCustom = false}) {
    return Chip(
      label: Text(label),
      backgroundColor: isAddCustom ? Colors.grey[300] : Colors.grey[200],
    );
  }

  Widget _buildRecentSamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Samples',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(
          leading: Icon(Icons.science, color: Colors.black),
          title: const Text('Sample #2847'),
          subtitle: const Text('2 hours ago'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.science, color: Colors.black),
          title: const Text('Sample #2846'),
          subtitle: const Text('5 hours ago'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recommendations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildRecommendationItem(
              'Increase Nitrogen',
              'Add organic compost to improve soil fertility',
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildRecommendationItem(
              'Adjust Irrigation',
              'Reduce watering frequency by 15%',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String subtitle, Color iconColor) {
    return Row(
      children: [
        Icon(Icons.circle, color: iconColor, size: 12),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}