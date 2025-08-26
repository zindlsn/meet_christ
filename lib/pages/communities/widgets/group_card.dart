import 'package:flutter/material.dart';
import 'package:meet_christ/models/group.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(group.name),
        subtitle: Text(group.description),
        leading: CircleAvatar(
          backgroundImage: group.profileImage != null
              ? MemoryImage(group.profileImage!)
              : null,
          child: group.profileImage == null ? Icon(Icons.person) : null,
        ),
      ),
    );
  }
}
