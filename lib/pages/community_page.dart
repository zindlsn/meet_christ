import 'package:flutter/material.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/pages/new_community_group_page.dart';
import 'package:meet_christ/pages/new_event_page.dart';
import 'package:meet_christ/widgets/event_card.dart';
import 'package:meet_christ/widgets/group_card.dart';

class CommunityPage extends StatefulWidget {
  final Community community;
  const CommunityPage({super.key, required this.community});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.community.name)),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom:8.0),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NewCommunityGroupPage(community: widget.community),
                  ),
                );
              },
              child: Icon(Icons.group_add),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NewEventPage(community: widget.community),
                ),
              );
            },
            child: Icon(Icons.event),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Description",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(widget.community.description),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  "Groups",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 500,
                child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: widget.community.groups.length,
                  itemBuilder: (context, index) {
                    final event = widget.community.groups[index];
                    return GroupCard(group: event);
                  },
                ),
              ),
              SizedBox(
                height: 500,
                child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: widget.community.events.length,
                  itemBuilder: (context, index) {
                    final event = widget.community.events[index];
                    return EventCard(event: event);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
