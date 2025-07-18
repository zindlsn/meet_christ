import 'package:flutter/material.dart';
import 'package:meet_christ/services/user_service.dart';

class ProfilePageViewModel extends ChangeNotifier{

  final UserService2 userService;

  ProfilePageViewModel({required this.userService});



  Future<void> logout() async{
    await userService.logout();
  }

}