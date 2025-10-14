import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/pages/chat_list_page.dart';
import 'package:meet_christ/pages/chat_page.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'chat_page_event.dart';
part 'chat_page_state.dart';

class ChatPageBloc extends Bloc<ChatPageEvent, ChatPageState> {
  ChatPageBloc() : super(ChatPageInitial()) {
    on<LoadChatPartner>(_onLoadChatPartner);
    on<StartChat>(_onStartChat);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadChatPartner(
    LoadChatPartner event,
    Emitter<ChatPageState> emit,
  ) async {
    /* var userData = await GetIt.I.get<UserService>().getUser(event.partnerId);
    UserModel me = GetIt.I.get<UserService>().user;

    ChatUserEntity = GetIt.I.get<ChatListRepository>();
    ChatUserModel other;
    if (userData != null) {
      other = ChatUserModel(
        userId: userData,
        displayName: userData.firstname + userData.lastname,
      );
    }
    var chat = SingleChatModel(
      id: id,
      creatorId: creatorId,
      me: participant1,
      other: participant2,
      messages: messages,
      createdAt: createdAt,
      title: title,
    );

    */
    // emit(ChatLoaded(chat: chat));
  }

  FutureOr<void> _onStartChat(
    StartChat event,
    Emitter<ChatPageState> emit,
  ) async {
    if (event.isNewChat && event.chatId == null) {
      var newChat = SingleChatEntity(
        id: Uuid().v4(),
        createdAt: DateTime.now(),
        creatorId: GetIt.I.get<UserService>().user.id,
        messages: [],
        participants: [
          ChatUserEntity(
            userId: GetIt.I.get<UserService>().user.id,
            displayName: "me",
          ),
          ChatUserEntity(userId: event.other.id, displayName: "Other"),
        ],
        lastMessage: "",
      );

      await GetIt.I.get<ChatListRepository>().createChat(newChat);

      var chat = SingleChatModel.fromEntity(newChat);
      emit(ChatLoaded(chat: chat));
    } else {
      var chat = await GetIt.I.get<ChatListRepository>().getChatById(
        event.chatId!,
      );

      GetIt.I.get<ChatListRepository>().markAllMessagesAsSeen(chat.id);

      var model = SingleChatModel.fromEntity(chat);
      emit(ChatLoaded(chat: model));
    }
  }

  FutureOr<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatPageState> emit,
  ) async {
    if (state is! ChatLoaded) return Future.value();
    final currentState = state as ChatLoaded;
    List<ChatMessageModel> messages = List<ChatMessageModel>.from(
      currentState.chat.messages,
    )..add(ChatMessageModel(text: event.text, isMe: true));

    var saved = GetIt.I.get<UserService>().user;

    var newState = currentState.chat.copyWith(messages: messages);
    bool isSentSuccess = await GetIt.I.get<ChatListRepository>().sendMessage(
      chatId: currentState.chat.id,
      message: ChatMessageEntity.newChat(saved, event.text, isSystem: false),
    );

    if (isSentSuccess) {
      emit(ChatMessageSentSucces());
    }
    emit(ChatLoaded(chat: newState));
  }
}
