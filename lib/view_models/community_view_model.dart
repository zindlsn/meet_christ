import 'package:flutter/material.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/services/community_service.dart';
import 'package:meet_christ/services/group_service.dart';
import 'package:meet_christ/services/user_service.dart';

class CommunityViewModel extends ChangeNotifier {
  CommunityService communitiesRepository;
  GroupService groupService;
  UserService userService;

  CommunityViewModel({
    required this.communitiesRepository,
    required this.userService,
    required this.groupService
  });
  List<Community> communities = [];
  bool isLoading = true;

  Future<void> loadCommunities() async {
    isLoading = true;
    notifyListeners();
    var savedCommunities = await  communitiesRepository.getAllCommunities(); //communitiesRepository.getUserCommunities(userService.user.id);
    for(Community c in savedCommunities){
     var  savedGroups = await groupService.getCommunityGroups(c.id);
      c.groups = savedGroups;
    }
    communities = savedCommunities;
    isLoading = false;
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
