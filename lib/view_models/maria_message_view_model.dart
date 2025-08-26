import 'package:flutter/material.dart';

class MariaMessageViewModel extends ChangeNotifier {
  final MariaMessageService mariaMessageService;
  MariaMessageViewModel({required this.mariaMessageService});
  String _message = "";
  String get message => _message;

  void updateMessage(String newMessage) {
    _message = newMessage;
    notifyListeners();
  }

  void showMariaMessageType(ShowMariaMessageType type) {

  }
  
}

enum ShowMariaMessageType{
  always,
  never,
  onlyNextMesage
}

class MariaMessageService {
  void showMessage(String message, ShowMariaMessageType type) {
    // Implement the logic to show the message based on the type
  }
}