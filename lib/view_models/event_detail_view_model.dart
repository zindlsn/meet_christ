import 'package:flutter/material.dart';
import 'package:meet_christ/models/event.dart';
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
    try {
      await eventService.rsvpToEvent(eventId, userService.user.id, isAttending);
      event.addAttendee(userService.user);
      notifyListeners();
    } catch (e) {
      print('Error joining event: $e');
      return false;
    }
    return true;
  }
}
