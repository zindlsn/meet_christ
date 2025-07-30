import 'package:flutter/material.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/group.dart';

class GroupCard extends StatefulWidget {
  final Group group;
  const GroupCard({super.key, required this.group});

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(
            widget.group.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(widget.group.description, style: TextStyle(fontSize: 16)),
          ElevatedButton(onPressed: () {}, child: const Text('Anfragen')),
        ],
      ),
    );
  }
}

class CommunityCard extends StatefulWidget {
  final Community event;
  const CommunityCard({super.key, required this.event});

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(
            widget.event.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(widget.event.description, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
