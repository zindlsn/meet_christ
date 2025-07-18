import 'package:flutter/material.dart';

class ChurchCard extends StatefulWidget {
  const ChurchCard({super.key});

  @override
  State<ChurchCard> createState() => _ChurchCardState();
}

class _ChurchCardState extends State<ChurchCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Evangelische Kirche Musterstadt",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Hier findet jeden Sonntag der Gottesdienst statt.",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
