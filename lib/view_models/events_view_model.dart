import 'package:flutter/material.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/event_types.dart';
import 'package:meet_christ/services/event_service.dart';

class EventsViewModel extends ChangeNotifier {
  final EventService eventService;
  EventsViewModel({required this.eventService});

  List<Event> events = [];

  List<String> filters = ["all"];
  List<String> timeFilter = [];

  bool isLoading = true;

  Future<void> loadEvents() async {
    isLoading = true;
    notifyListeners();
    events = await eventService.getAll();

    if (timeFilter.contains("today")) {
      events = events.where((event) {
        return event.startDate.isAfter(
              DateTime.now().subtract(Duration(days: 1)),
            ) &&
            event.startDate.isBefore(DateTime.now().add(Duration(days: 1)));
      }).toList();
    } else if (timeFilter.contains("thisweek")) {
      final startOfWeek = DateTime.now().subtract(
        Duration(days: DateTime.now().weekday - 1),
      );
      final endOfWeek = startOfWeek.add(Duration(days: 6));
      events = events.where((event) {
        return event.startDate.isAfter(DateTime.now()) &&
            event.startDate.isBefore(endOfWeek);
      }).toList();
    }
    if (filters.contains(EventTypes.all)) {
    } else if (filters.contains(EventTypes.community)) {
      events = events
          .where((event) => event.type == EventTypes.community)
          .toList();
    } else if (filters.contains(EventTypes.worshipService)) {
      events = events
          .where((event) => event.type == EventTypes.worshipService)
          .toList();
    } else if (filters.contains(EventTypes.event)) {
      events = events.where((event) => event.type == EventTypes.event).toList();
    } else if (filters.contains(EventTypes.bibleStudy)) {
      events = events
          .where((event) => event.type == EventTypes.bibleStudy)
          .toList();
    } else if (filters.contains(EventTypes.prayerMeeting)) {
      events = events
          .where((event) => event.type == EventTypes.prayerMeeting)
          .toList();
    } else if (filters.contains(EventTypes.youthGroup)) {
      events = events
          .where((event) => event.type == EventTypes.youthGroup)
          .toList();
    } else if (filters.contains(EventTypes.fellowship)) {
      events = events
          .where((event) => event.type == EventTypes.fellowship)
          .toList();
    }
    isLoading = false;
    notifyListeners();
  }

  void removeEvent(EventDto event) {
    events.remove(event);
    notifyListeners();
  }

  List<Event> getEvents() {
    return events;
  }

  List<Event> getEventsAttending() {
    return events
        .where((event) => event.attendees.any((attendee) => attendee.id == "1"))
        .toList();
  }

  void addAttendantToEvent(Event event) {
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      if (events[index].attendees.any((attendee) => attendee.id == "1")) {
        events[index].attendees.removeWhere((attendee) => attendee.id == "1");
      } else {
        // events[index].attendees.add();
      }
      notifyListeners();
    }
  }
}
