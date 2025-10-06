import 'package:flutter/material.dart';
import 'package:meet_christ/repositories/auth_repository.dart';

class ProfilePageViewModel extends ChangeNotifier{

  final AuthRepository authRepository;

  ProfilePageViewModel({required this.authRepository});



  Future<void> logout() async{
    await authRepository.logout();
  }

}