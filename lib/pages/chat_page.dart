import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/pages/chat_list_page.dart';
import 'package:meet_christ/view_models/chatpage/bloc/chat_page_bloc.dart';

class ChatPage extends StatelessWidget {
  final UserModel partner;
  final bool isNewChat;
  final String? chatId;

  const ChatPage({
    super.key,
    required this.partner,
    this.isNewChat = false,
    this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ChatPageBloc()..add(StartChat(partner, chatId, isNewChat: isNewChat)),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();

  void _send(BuildContext context) {
    if (_messageController.text.trim().isEmpty) return;
    context.read<ChatPageBloc>().add(SendMessage(_messageController.text));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatPageBloc, ChatPageState>(
      builder: (context, state) {
        if (state is ChatPageInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ChatLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ChatLoadedFailed) {
          return const Scaffold(
            body: Center(child: Text('Failed to load chat')),
          );
        } else if (state is ChatLoaded) {
          final chat = (state as ChatLoaded).chat;
          return Scaffold(
            appBar: AppBar(title: Text(chat.title)),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: chat.messages.length,
                      itemBuilder: (context, index) {
                        final msg = chat.messages[index];
                        return Align(
                          alignment: msg.isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: msg.isMe
                                  ? Colors.blue[100]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(msg.text),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _send(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () => _send(context),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isSystem;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.isMe = false,
    this.isSystem = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            message,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            Text(message),
            Text(isMe.toString())
          ],
        ),
      ),
    );
  }
}

class ChatMessageModel {
  final String text;
  final bool isMe;

  ChatMessageModel({required this.text, required this.isMe});

  static ChatMessageModel fromEntity(ChatMessageEntity msg, bool isMe) {
    return ChatMessageModel(text: msg.text, isMe: isMe);
  }
}

class ChatModel {
  final ChatUserModel me;
  final ChatUserModel other;
  final String title;
  final List<ChatMessageModel> messages = [];
  ChatModel({required this.me, required this.other, required this.title});

  ChatModel copyWith({ChatUserModel? me, ChatUserModel? other, String? title}) {
    return ChatModel(
      me: me ?? this.me,
      other: other ?? this.other,
      title: title ?? this.title,
    );
  }
}
