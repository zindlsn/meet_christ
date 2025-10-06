import 'package:flutter/material.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/events_filter.dart';
import 'package:meet_christ/models/user.dart';
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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String city = "";
  String get _city => city;

  void setCity(String city) {
    this.city = city;
    notifyListeners();
  }

  Future<void> loadEventsWithFilter() async {
    EventsFilter currentFilter = EventsFilter();

    if (city.isNotEmpty) {
      currentFilter.location = _city;
    }

    events = [];
    _isLoading = true;
    events = await eventService.getEventsWithoutGroup(currentFilter);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadEvents(EventsFilter filter) async {
    events = [];
    _isLoading = true;
    events = await eventService.getEventsWithoutGroup(filter);
    _isLoading = false;
    notifyListeners();
  }

  List<Event> getEvents() {
    return events;
  }

  Future<void> loadAttendingEvents() async {
    //print("Loading attending events for user ${userService.user.id}");
    var loadedEvents = await eventService.getUserEvents(userService.user.id);
    attendingEvents = loadedEvents;

    
    notifyListeners();
  }

  void addAttendantToEvent(Event event) {
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      if (events[index].attendees.any(
        (attendee) => attendee.userId == userService.user.id,
      )) {
        events[index].attendees.removeWhere(
          (attendee) => attendee.userId == userService.user.id,
        );
      } else {
        events[index].attendees.add(
          EventUser.attendee(userService.user.id, event.id),
        );
      }
      notifyListeners();
    }
  }

  Future<void> reload() async {
    await loadEvents(filter);
  }

  EventsFilter filter = EventsFilter();

  void setFilter(EventsFilter filter) {
    this.filter = filter;
  }
}
