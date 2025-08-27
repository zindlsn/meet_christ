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

  void saveEvent() {}

  void loadMyCommunities() async {
    communities = await communitiesRepository.getAllCommunities();
    notifyListeners();
  }

  Group? selectedGroup;
  Community? selectedCommunity;

  Uint8List? imageAsBytes;

  void setImage(Uint8List? image) {
    imageAsBytes = image;
    notifyListeners();
  }

  String title = "";
  void setTitle({required String title}) {
    this.title = title;
    notifyListeners();
  }

  void setSelectedCommunity(Community? time) {
    selectedCommunity = time;
    notifyListeners();
  }

  void setSelectedGroup(Group? time) {
    selectedGroup = time;
    notifyListeners();
  }

  /// saves a new event
  Future<void> saveNewEvent() async {
    var eventId = Uuid().v4();
    var event = Event(
      id: eventId,
      title: title.isNotEmpty ? title : 'New Event',
      description: '',
      attendees: [],
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
      location: 'Event Location',
      image: imageAsBytes,
    );

    eventService.createEvent(event: event);
    notifyListeners();
  }

  void setSelectedStartTime(TimeOfDay time) {
    _selectedStartTime = time;
    notifyListeners();
  }

  void setSelectedEndTime(TimeOfDay time) {
    _selectedEndTime = time;
    notifyListeners();
  }

  void setSelectedStartDate(DateTime date) {
    selectedStartDate = date;
    notifyListeners();
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
    notifyListeners();
  }

  void setSelectedEndDate(DateTime picked) {
    _selecteEnddDate = picked;
    notifyListeners();
  }
}
