import 'package:flutter/material.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/services/community_service.dart';

class CommunityViewModel extends ChangeNotifier {
  CommunityService communitiesRepository;

  CommunityViewModel({required this.communitiesRepository});
  List<Community> communities = [];
  bool isLoading = true;

  Future<void> loadCommunities() async {
    var saved = await communitiesRepository.getAll();
    isLoading = false;
    notifyListeners();
    communities = saved;
    notifyListeners();
  }

  Future<void> loadEventsSortByCity() async {
    isLoading = true;
    notifyListeners();
    isLoading = false;
    notifyListeners();
  }

  // Example methods
  void addEvent(Community event) {
    communities.add(event);
    notifyListeners(); // Notify listeners that the state has changed
  }

  void removeEvent(String event) {
    communities.remove(event);
    notifyListeners(); // Notify listeners that the state has changed
  }

  List<Community> getEvents() {
    return communities; // Return the current list of events
  }
}
