import 'package:flutter/material.dart';
import 'package:meet_christ/models/community.dart';
import 'package:meet_christ/models/group.dart';
import 'package:meet_christ/services/group_service.dart';
import 'package:meet_christ/services/user_service.dart';

class NewCommunityGroupPageViewModel extends ChangeNotifier {
  GroupService groupService;
  UserService userService;
  NewCommunityGroupPageViewModel({
    required this.groupService,
    required this.userService,
  });

  String name = "";
  void setName(String name) {
    this.name = name;
    notifyListeners();
  }

  Future<void> saveConnumityGroup() async {
    Group group = Group.newNewGroup(name);
    group.community = community;
    group.createdOn = DateTime.now();
    group.createdBy = userService.user.id;
    group.admins.add(userService.user);
    group.members.add(userService.user);
    await groupService.createGroup(group: group);
  }

  late Community community;
  void setCommunity(Community community) {
    this.community = community;
  }
}
