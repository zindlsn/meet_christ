import 'package:flutter/material.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/event_types.dart';
import 'package:meet_christ/services/community_service.dart';
import 'package:meet_christ/services/event_service.dart';
import 'package:meet_christ/services/user_service.dart';

class EventsViewModel extends ChangeNotifier {
  final EventService eventService;
  final CommunityService communityService;
  final UserService userService;
  EventsViewModel({
    required this.eventService,
    required this.communityService,
    required this.userService,
  });

  List<Event> events = [];
  List<Event> attendingEvents = [];

  List<String> filters = ["all"];
  List<String> timeFilter = [];

  bool isLoading = false;
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  void setIsLoaded(bool attend) {
    _isLoaded = attend;
  }

  Future<void> loadEvents() async {
    isLoading = true;
    notifyListeners();
    events = await eventService.getEventsWithoutGroup();
    isLoading = false;
    setIsLoaded(true);
    notifyListeners();
  }

  void removeEvent(EventDto event) {
    events.remove(event);
    notifyListeners();
  }

  List<Event> getEvents() {
    return events;
  }

  Future<void> loadAttendingEvents() async {
    var loadedEvents = await eventService.getUserEvents(userService.user.id);
    attendingEvents = loadedEvents;
    notifyListeners();
  }

  void addAttendantToEvent(Event event) {
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      if (events[index].attendees.any(
        (attendee) => attendee.id == userService.loggedInUser!.id,
      )) {
        events[index].attendees.removeWhere(
          (attendee) => attendee.id == userService.loggedInUser!.id,
        );
      } else {
        events[index].attendees.add(userService.loggedInUser!);
      }
      notifyListeners();
    }
  }
}
