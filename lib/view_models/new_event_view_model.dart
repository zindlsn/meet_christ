import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/event.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/services/community_service.dart';
import 'package:meet_christ/services/event_service.dart';
import 'package:uuid/uuid.dart';

class NewEventViewModel extends ChangeNotifier {
  DateTime selectedStartDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  CommunityService communitiesRepository;

  EventService eventService;

  NewEventViewModel({
    required this.communitiesRepository,
    required this.eventService,
  });

  late List<Community> communities = [];
  List<CommunityGroup> groups = [];

  void saveEvent() {}

  void loadMyCommunities() async {
    notifyListeners();
  }

  CommunityGroup? selectedGroup;
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

  void setSelectedGroup(CommunityGroup? time) {
    selectedGroup = time;
    notifyListeners();
  }

  /// saves a new event
  Future<void> saveNewEvent() async {
    var event = Event(
      id: Uuid().v4(),
      title: title.isNotEmpty ? title : 'New Event',
      description: 'Description of the new event',
      startDate: DateTime(
        selectedStartDate.year,
        selectedStartDate.month,
        selectedStartDate.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      ),
      endDate: DateTime(
        selectedStartDate.year,
        selectedStartDate.month,
        selectedStartDate.day,
        _selectedStartTime.hour + 1, // Assuming the event lasts for 1 hour
        _selectedStartTime.minute,
      ),
      location: 'Event Location',
      image: imageAsBytes,
    );

    eventService.create(event);
    notifyListeners();
  }

  void setSelectedStartTime(TimeOfDay time) {
    _selectedStartTime = time;
    notifyListeners();
  }

  void setSelectedStartDate(DateTime date) {
    selectedStartDate = date;
    notifyListeners();
  }
}
