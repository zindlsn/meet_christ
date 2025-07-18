import 'package:flutter/material.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/view_models/events_view_model.dart';
import 'package:provider/provider.dart';

class EventCard extends StatefulWidget {
  final Event event;
  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          widget.event.image != null
              ? Image.memory(widget.event.image!)
              : Container(),
          Text(
            widget.event.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(widget.event.description, style: TextStyle(fontSize: 16)),
          Text('Start: ${widget.event.startDate.toLocal()}'),
          Text('End: ${widget.event.endDate.toLocal()}'),
          Text('Location: ${widget.event.location}'),

          ElevatedButton(
            onPressed: () {
              Provider.of<EventsViewModel>(
                context,
                listen: false,
              ).addAttendantToEvent(widget.event);
            },
            child: Row(
              children: [
                Text("Teilnehmer: ${widget.event.attendees.length}"),
                Spacer(),
                widget.event.attendees.contains(
                      User(id: "", name: "", email: ""),
                    )
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.check),
                          const Text("Bin dabei"),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [const Text('Attend')],
                      ),
              ],
            ),
          ),
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
