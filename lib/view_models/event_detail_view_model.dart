import 'package:flutter/material.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/services/event_service.dart';
import 'package:meet_christ/services/user_service.dart';

class EventDetailViewModel extends ChangeNotifier {
  final EventService eventService;
  final UserService userService;

  EventDetailViewModel({required this.eventService, required this.userService});

  late Event event;

  void setEvent(Event event) {
    this.event = event;
    _isAttending = event.meAttending;
  }

  bool _isAttending = false;
  bool get isAttending => _isAttending;

  void setIsAttending(bool attend) {
    _isAttending = attend;
    notifyListeners();
  }

  Future<bool> joinEvent(String eventId) async {
    var eventUser = EventUser.attendee(userService.user.id, eventId);
    try {
      await eventService.rsvpToEvent(eventUser, true);
      event.addAttendee(eventUser);
      notifyListeners();
    } catch (e) {
      return false;
    }
    return true;
  }
}
