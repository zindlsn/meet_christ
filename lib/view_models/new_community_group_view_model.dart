import 'package:flutter/material.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/services/community_service.dart';
import 'package:meet_christ/services/user_service.dart';

class NewCommunityGroupPageViewModel extends ChangeNotifier {
  CommunityService communityService;
  UserService2 userService;
  NewCommunityGroupPageViewModel({
    required this.communityService,
    required this.userService,
  });

  String name = "";
  void setName(String name) {
    this.name = name;
    notifyListeners();
  }

  Future<void> saveConnumityGroup() async {
    CommunityGroup group = CommunityGroup.newNewGroup(name);
    group.communityId = community.id;
    group.createdOn = DateTime.now();
    group.createdBy = userService.loggedInUser!.id;
    List<CommunityGroup> groups = [];
    groups.addAll(community.groups);
    groups.add(group);
    var updatedCommunity = community.copyWith(groups: groups);
    await communityService.update(updatedCommunity);
  }

  late Community community;
  void setCommunity(Community community) {
    this.community = community;
  }
}
