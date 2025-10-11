import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/pages/chat_page.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meet_christ/view_models/chatlist/bloc/chatlist_bloc.dart';
import 'package:meet_christ/view_models/userlist/bloc/user_list_bloc.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    context.read<ChatlistBloc>().add(FetchChatListEvent());
    context.read<UserListBloc>().add(FetchUserListEvent());
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
      body: BlocConsumer<ChatlistBloc, ChatlistState>(
        listener: (context, state) {},
        builder: (context, state) {
          return SingleChildScrollView(
            child: SizedBox(
              height: 800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: state is ChatlistLoaded
                        ? Column(
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
                              Expanded(
                                child: ListView.builder(
                                  itemCount: state.chats.length,
                                  primary: false,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        child: Text(
                                          'User ${index + 1}',
                                        ), // First letter of name
                                      ),
                                      title: Text("chat.name"),
                                      subtitle: Text("chat.lastMessage"),
                                      trailing: 2 > 0
                                          ? CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Colors.blue,
                                              child: Text(
                                                2.toString(),
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
                                            builder: (context) => ChatPage(
                                              chatId: state.chats[index].id,
                                              partner:
                                                  state.chats[index].other.user,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  Text('Start a new chat'),
                  SizedBox(
                    height: 300,
                    child: BlocConsumer<UserListBloc, UserListState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        return state is UserListLoaded
                            ? ListView.builder(
                                itemCount: state.users.length,
                                primary: false,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        state.users[index].firstname.isNotEmpty
                                            ? state.users[index].firstname[0]
                                            : '?',
                                      ), // First letter of name
                                    ),
                                    title: Text(state.users[index].firstname),
                                    subtitle: Text(state.users[index].lastname),

                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            partner: state.users[index],
                                            isNewChat: true,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            : const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ],
              ),
            ),
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

class SingleChatModel {
  final String id;
  final String creatorId;
  final ChatUserModel me;
  final ChatUserModel other;
  final List<ChatMessageModel> messages;
  final String? lastMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final String title;

  SingleChatModel({
    required this.id,
    required this.creatorId,
    required this.me,
    required this.other,
    required this.messages,
    this.lastMessage,
    required this.createdAt,
    required this.title,
    this.updatedAt,
  });

  SingleChatModel.fromEntity(SingleChatEntity entity)
    : id = entity.id,
      creatorId = entity.creatorId,
      me = ChatUserModel(
        user: UserModel.empty(), // Fetch user details as needed
        displayName: entity.participants[0].displayName,
        isMuted: entity.participants[0].isMuted,
        lastSeen: entity.participants[0].lastSeen,
        isTyping: entity.participants[0].isTyping,
      ),
      other = ChatUserModel(
        user: UserModel.empty(), // Fetch user details as needed
        displayName: entity.participants[1].displayName,
        isMuted: entity.participants[1].isMuted,
        lastSeen: entity.participants[1].lastSeen,
        isTyping: entity.participants[1].isTyping,
      ),
      messages = entity.messages
          .map(
            (msg) => ChatMessageModel.fromEntity(
              msg,
              msg.senderId == entity.participants[0].userId,
            ),
          )
          .toList(),
      lastMessage = entity.lastMessage,
      createdAt = entity.createdAt,
      updatedAt = entity.updatedAt,
      title = "Chat with ${entity.participants[1].displayName}";
  SingleChatModel copyWith({
    String? id,
    String? creatorId,
    ChatUserModel? me,
    ChatUserModel? other,
    List<ChatMessageModel>? messages,
    String? lastMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
  }) {
    return SingleChatModel(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      me: me ?? this.me,
      other: other ?? this.other,
      messages: messages ?? List<ChatMessageModel>.from(this.messages),
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
    );
  }
}

/// API
class SingleChatEntity {
  final String id;
  final String creatorId;
  final List<ChatUserEntity> participants;
  final List<ChatMessageEntity> messages;
  final String? lastMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SingleChatEntity({
    required this.id,
    required this.creatorId,
    required this.participants,
    required this.messages,
    this.lastMessage,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorId': creatorId,
      'participants': participants.map((p) => p.toMap()).toList(),
      'participantIds': participants.map((p) => p.userId).toList(),
      // Normally messages would be stored in a subcollection, but keeping for serialization completeness
      'messages': messages.map((m) => m.toMap()).toList(),
      'lastMessage': lastMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SingleChatEntity.fromMap(
    Map<String, dynamic> map,
    List<ChatMessageEntity> messages,
  ) {
    return SingleChatEntity(
      id: map['id'],
      creatorId: map['creatorId'],
      participants: (map['participants'] as List<dynamic>)
          .map((e) => ChatUserEntity.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      messages: messages, // You’ll load subcollection messages separately
      lastMessage: map['lastMessage'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
                ? (map['updatedAt'] as Timestamp).toDate()
                : DateTime.parse(map['updatedAt']))
          : null,
    );
  }

  /// 🧩 Immutability helper
  SingleChatEntity copyWith({
    String? id,
    String? creatorId,
    List<ChatUserEntity>? participants,
    List<ChatMessageEntity>? messages,
    String? lastMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SingleChatEntity(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      participants:
          participants ?? List<ChatUserEntity>.from(this.participants),
      messages: messages ?? List<ChatMessageEntity>.from(this.messages),
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatUserModel {
  final UserModel user;
  final String displayName;
  final bool isMuted;
  final DateTime? lastSeen;
  final bool isTyping;

  ChatUserModel({
    required this.user,
    required this.displayName,
    this.isMuted = false,
    this.lastSeen,
    this.isTyping = false,
  });
}

class ChatUserEntity {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final bool isMuted;
  final DateTime? lastSeen;
  final bool isTyping;

  ChatUserEntity({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.isMuted = false,
    this.lastSeen,
    this.isTyping = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'isMuted': isMuted,
      'lastSeen': lastSeen?.toIso8601String(),
      'isTyping': isTyping,
    };
  }

  factory ChatUserEntity.fromMap(Map<String, dynamic> map) {
    return ChatUserEntity(
      userId: map['userId'],
      displayName: map['displayName'],
      isMuted: map['isMuted'] ?? false,
      lastSeen: map['lastSeen'] != null
          ? DateTime.parse(map['lastSeen'])
          : null,
      isTyping: map['isTyping'] ?? false,
    );
  }
}

class Chat {
  final String name;
  final String lastMessage;
  final int unread;
  final String meId;
  final String otherId;
  final List<ChatMessageEntity> messages = [];

  Chat({
    required this.name,
    required this.lastMessage,
    required this.unread,
    required this.meId,
    required this.otherId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastMessage': lastMessage,
      'unread': unread,
      'meId': meId,
      'otherId': otherId,
      'messages': messages.map((msg) => msg.toMap()).toList(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      name: map['name'],
      lastMessage: map['lastMessage'],
      unread: map['unread'],
      meId: map['meId'],
      otherId: map['otherId'],
    );
  }
}

class ChatMessageEntity {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool isSystem;

  /// List of user IDs who have received the message
  final List<String> receivedBy;

  /// List of user IDs who have seen (read) the message
  final List<String> seenBy;

  ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.receivedBy = const [],
    this.seenBy = const [],
    this.isSystem = false,
  });

  ChatMessageEntity newChat(
    UserModel model,
    String text, {
    bool isSystem = false,
  }) {
    return ChatMessageEntity(
      id: model.id + DateTime.now().toIso8601String(),
      senderId: model.id,
      text: text,
      sentAt: DateTime.now(),
      isSystem: isSystem,
    );
  }

  ChatMessageEntity copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? sentAt,
    List<String>? receivedBy,
    List<String>? seenBy,
    bool? isSystem,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      receivedBy: receivedBy ?? this.receivedBy,
      seenBy: seenBy ?? this.seenBy,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'sentAt': sentAt.toIso8601String(),
      'receivedBy': receivedBy,
      'seenBy': seenBy,
      'isSystem': isSystem,
    };
  }

  factory ChatMessageEntity.fromMap(Map<String, dynamic> map) {
    return ChatMessageEntity(
      id: map['id'] ?? "0",
      senderId: map['senderId'],
      text: map['text'],
      sentAt: (map['createdAt'] as Timestamp).toDate(),
      receivedBy: List<String>.from(map['receivedBy'] ?? []),
      seenBy: List<String>.from(map['seenBy'] ?? []),
      isSystem: map['isSystem'] ?? false,
    );
  }
}
