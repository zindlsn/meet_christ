import 'package:flutter/material.dart';
import 'package:meet_christ/pages/chat_page.dart';
import 'package:meet_christ/pages/ki_chat_page.dart';
import 'package:meet_christ/view_models/chat_list_view_model.dart';
import 'package:provider/provider.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  @override
  void initState() {
    Provider.of<ChatListViewModel>(context, listen: false).fetchChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add search functionality
            },
          ),
        ],
      ),
      body: Consumer<ChatListViewModel>(
        builder: (context, model, child) {
          return Column(
            children: [
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 80,
                      child: Card(
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  child: Text("AI"), // First letter of name
                ),
                title: Text("AI Assistant"),
                subtitle: Text(model.chats[3].lastMessage),
                trailing: model.chats[3].unread > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue,
                        child: Text(
                          model.chats[3].unread.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          KIChatPage(chatName: model.chats[3].name),
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: model.chats.length,
                  primary: false,
                  itemBuilder: (context, index) {
                    final chat = model.chats[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(chat.name[0]), // First letter of name
                      ),
                      title: Text(chat.name),
                      subtitle: Text(chat.lastMessage),
                      trailing: chat.unread > 0
                          ? CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue,
                              child: Text(
                                chat.unread.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(chatName: chat.name),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () {
          // Add new chat functionality
        },
      ),
    );
  }
}

class Chat {
  final String name;
  final String lastMessage;
  final int unread;

  Chat({required this.name, required this.lastMessage, required this.unread});
}
