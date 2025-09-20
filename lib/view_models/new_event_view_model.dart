import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/services/community_service.dart';
import 'package:meet_christ/services/event_service.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:uuid/uuid.dart';

class NewEventViewModel extends ChangeNotifier {
  DateTime selectedStartDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  DateTime _selecteEnddDate = DateTime.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();

  CommunityService communitiesRepository;
  UserService userService;
  EventService eventService;

  NewEventViewModel({
    required this.userService,
    required this.communitiesRepository,
    required this.eventService,
  });

  List<Community> communities = [];
  List<Group> groups = [];

  void loadMyCommunities() async {
    communities = await communitiesRepository.getAllCommunities();
    notifyListeners();
  }

  Group? selectedGroup;
  Community? selectedCommunity;

  Uint8List? imageAsBytes;

  void setImage(Uint8List? image) {
    imageAsBytes = image;
  }

  String title = "";
  void setTitle({required String title}) {
    this.title = title;
  }

  String location = "";
  void setLocation({required String location}) {
    this.location = location;
  }

  void setSelectedCommunity(Community? time) {
    selectedCommunity = time;
  }

  void setSelectedGroup(Group? time) {
    selectedGroup = time;
  }

  /// saves a new event
  Future<void> saveNewEvent() async {
    var eventId = Uuid().v4();
    var event = Event(
      id: eventId,
      title: title.isNotEmpty ? title : 'New Event',
      description: '',
      attendees: [EventUser.attendee(userService.user.id, eventId)],
      organizers: [EventUser.host(userService.user.id, eventId)],
      startDate: DateTime(
        selectedStartDate.year,
        selectedStartDate.month,
        selectedStartDate.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      ),
      endDate: DateTime(
        _selecteEnddDate.year,
        _selecteEnddDate.month,
        _selecteEnddDate.day,
        _selectedEndTime.hour,
        _selectedEndTime.minute,
      ),
      location: location,
      image: imageAsBytes,
    );

    eventService.createEvent(event: event);
    notifyListeners();
  }

  void setSelectedStartTime(TimeOfDay time) {
    _selectedStartTime = time;
  }

  void setSelectedEndTime(TimeOfDay time) {
    _selectedEndTime = time;
  }

  void setSelectedStartDate(DateTime date) {
    selectedStartDate = date;
  }

  Future initCommunity(Community? community) async {
    loadMyCommunities();
    for (Community c in communities) {
      if (c.id == community?.id) {
        selectedCommunity = c;
        notifyListeners();
        return;
      }
    }
  }

  void setSelectedEndDate(DateTime picked) {
    _selecteEnddDate = picked;
  }
}
