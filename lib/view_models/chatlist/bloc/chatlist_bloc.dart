import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/pages/chat_list_page.dart';
import 'package:meet_christ/pages/chat_page.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meta/meta.dart';

part 'chatlist_event.dart';
part 'chatlist_state.dart';

class ChatlistBloc extends Bloc<ChatlistEvent, ChatlistState> {
  StreamSubscription? _chatsSub;
  final _messageListeners = <StreamSubscription>[];

  ChatlistBloc() : super(ChatlistInitial()) {
    _listenToChats();
    on<ChatlistEvent>((event, emit) {});
    on<FetchChatListEvent>((event, emit) async {
      emit(ChatlistLoading());
      List<SingleChatEntity> chats = await GetIt.I
          .get<ChatListRepository>()
          .fetchChats(GetIt.I.get<UserService>().user.id);
      List<SingleChatModel> chatModels = [];

      print(GetIt.I.get<UserService>().user.id);

      chatModels = await toModels(chats);
      emit(ChatlistLoaded(chatModels));
    });
    on<ChatlistUpdated>((event, emit) {
      emit(ChatlistLoaded(event.chatModels));
    });
  }

  Future<List<SingleChatModel>> toModels(List<SingleChatEntity> chats) async {
    List<SingleChatModel> chatModels = [];
    for (SingleChatEntity entity in chats) {
      var meModel;
      var other;
      for (ChatUserEntity participant in entity.participants) {
        if (participant.userId == GetIt.I.get<UserService>().user.id) {
          meModel = ChatUserModel(
            user: GetIt.I.get<UserService>().user,
            isMuted: participant.isMuted,
            isTyping: participant.isTyping,
            lastSeen: participant.lastSeen,
            displayName: "displaynmae",
          );
        } else {
          var otherUserModel = await GetIt.I.get<UserService>().getUser(
            participant.userId,
          );
          if (otherUserModel != null) {
            other = ChatUserModel(
              user: otherUserModel,
              isMuted: participant.isMuted,
              isTyping: participant.isTyping,
              lastSeen: participant.lastSeen,
              displayName: "displaynmae",
            );
          } else {
            return [];
          }
        }
      }

      chatModels.add(
        SingleChatModel(
          id: entity.id,
          creatorId: entity.creatorId,
          me: meModel,
          other: other,
          messages: entity.messages
              .map(
                (message) => ChatMessageModel.fromEntity(
                  message,
                  message.senderId == GetIt.I.get<UserService>().user.id,
                ),
              )
              .toList(),
          createdAt: entity.createdAt,
          title: "Chatroom",
        ),
      );
    }
    return chatModels;
  }

  void _listenToChats() {
    _chatsSub?.cancel();
    final userId = GetIt.I.get<UserService>().user.id;
    final chatRepo = GetIt.I.get<ChatListRepository>();

    _chatsSub = FirebaseFirestore.instance
        .collection('singlechats')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .listen(
          (snapshot) async {
            try {
              // 1️⃣ Map Firestore docs → entities → models
              final entities = snapshot.docs
                  .map((doc) => SingleChatEntity.fromMap(doc.data(), []))
                  .toList();

              final chatModels = await toModels(entities);

              // 2️⃣ Cancel previous message listeners
              for (final sub in _messageListeners) {
                await sub.cancel();
              }
              _messageListeners.clear();

              // 3️⃣ Listen for messages per chat
              for (final chat in snapshot.docs) {
                final chatId = chat.id;

                final msgSub = chat.reference
                    .collection('messages')
                    .snapshots()
                    .listen((msgSnap) {
                      // 4️⃣ Count messages where seenBy[] doesn't include the userId
                      int unreadCount = msgSnap.docs.where((m) {
                        final data = m.data();
                        final seenBy = List<String>.from(data['seenBy'] ?? []);
                        final createdBy = data['creatorId'] as String? ?? '';

                        // ✅ Only count if current user hasn't seen it AND didn't send it
                        return !seenBy.contains(userId) && createdBy != userId;
                      }).length;

                      // 5️⃣ Update model
                      final idx = chatModels.indexWhere((c) => c.id == chatId);
                      if (idx != -1) {
                        chatModels[idx].newMessageCount = unreadCount;
                      }

                      // 6️⃣ Emit new state (clone list to trigger rebuild)
                      add(ChatlistUpdated(chatModels: List.of(chatModels)));
                    });

                _messageListeners.add(msgSub);
              }

              // 7️⃣ Initial UI update
              add(ChatlistUpdated(chatModels: List.of(chatModels)));
            } catch (e, st) {
              print('🔥 Firestore listener error: $e\n$st');
            }
          },
          onError: (error) {
            print('🔥 Error listening to chats: $error');
          },
        );
  }
}
