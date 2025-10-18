import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/event.dart';
import 'package:uuid/uuid.dart';

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
      clipBehavior: Clip.antiAlias,
      color: Colors.blueGrey[100],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.event.image != null
                ? Image.asset('assets/images/cross.jpg')
                : SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Hero(
                          tag: 'dash1' + Uuid().v4(),
                          child: Image.asset(
                            "assets/images/placeholder_church.png",
                            fit: BoxFit.fill,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                          left: 4, // Distance from the left edge
                          bottom: 4, // Distance from the bottom edge
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${widget.event.attendees.length} gehen',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                widget.event.title.toUpperCase(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Text("Test"),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'Ignite Ludwigsburg',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                formatDateTime(widget.event.startDate),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: GestureDetector(
                onTap: () {
                  MapsLauncher.launchQuery(widget.event.location);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.event.location),
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Icon(Icons.open_in_new, size: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
    return SizedBox(
      height: 100,
      child: Card(
        child: Column(
          children: [
            Text(
              widget.event.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(widget.event.description, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

String formatDateTime(DateTime dateTime, {bool isLong = false}) {
  // Custom weekday abbreviations
  const List<String> weekdayAbbr = ['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'];
  const List<String> weekdayAbbrLong = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];
  String dayAbbr = "";
  if (!isLong) {
    // Get weekday abbreviation (Note: DateTime.weekday: 1 - Monday, 7 - Sunday)
    dayAbbr = weekdayAbbr[dateTime.weekday - 1];
  } else {
    dayAbbr = weekdayAbbrLong[dateTime.weekday - 1];
  }
  // Get uppercase month abbreviation
  String monthAbbr = DateFormat.MMM().format(dateTime).toUpperCase();

  // Get day and time
  String day = DateFormat.d().format(dateTime);
  String time = DateFormat.Hm().format(dateTime); // 24-hour format "14:12"

  // Combine
  return '$dayAbbr, $monthAbbr $day - $time';
}
