import 'package:flutter/material.dart';
import 'package:meet_christ/pages/chat_list_page.dart';

class ChatListViewModel extends ChangeNotifier {
  List<Chat> chats = [];

  Future<void> fetchChats() async {
    // Simulate fetching chats from a service
    await Future.delayed(Duration(seconds: 1));
    chats = [
      Chat(name: "Chat 1", lastMessage: "Hello!", unread: 0),
      Chat(name: "Chat 2", lastMessage: "How are you?", unread: 2),
      Chat(name: "Chat 3", lastMessage: "Let's meet", unread: 1),
      Chat(name: "AI Assistant", lastMessage: "Ready to assist!", unread: 0),
    ];
    notifyListeners();
  }
}
