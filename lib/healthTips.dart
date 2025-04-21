import 'package:flutter/material.dart';

void main() {
  runApp(HealthTipsApp());
}

class HealthTipsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tips',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HealthTipsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HealthTipsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Good Afternoon, Sarina!'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Health Tips', true),
                  SizedBox(width: 8),
                  _buildFilterChip('Category', false),
                  SizedBox(width: 8),
                  _buildFilterChip('Favourite', false),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Today's Health Tip
            _buildTipCard(
              title: 'Today Health Tips',
              content: 'Drink more water to stay hydrated',
              icon: Icons.local_drink,
              color: Colors.blue[100]!,
            ),
            SizedBox(height: 16),

            // Today's Mental Tip
            _buildTipCard(
              title: 'Today Mental Tips',
              content: 'Spend time in nature to improve your mood and mental clarity',
              icon: Icons.nature,
              color: Colors.green[100]!,
            ),
          ],
        ),
      ),
      //floatingActionButton: FloatingActionButton(
        //child: Icon(Icons.add),
        //onPressed: () {},
      //),
    );
  }

  Widget _buildFilterChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool value) {},
      selectedColor: Colors.blue[200],
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: selected ? Colors.blue[800] : Colors.grey[600],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTipCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.blue[800]),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}