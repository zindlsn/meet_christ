import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/pages/chat_list_page.dart';
import 'package:meet_christ/pages/chat_page.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meta/meta.dart';

part 'chatlist_event.dart';
part 'chatlist_state.dart';

class ChatlistBloc extends Bloc<ChatlistEvent, ChatlistState> {
  ChatlistBloc() : super(ChatlistInitial()) {
    on<ChatlistEvent>((event, emit) {});
    on<FetchChatListEvent>((event, emit) async {
      emit(ChatlistLoading());
      List<SingleChatEntity> chats = await GetIt.I
          .get<ChatListRepository>()
          .fetchChats(GetIt.I.get<UserService>().user.id);
      List<SingleChatModel> chatModels = [];

      for (SingleChatEntity entity in chats) {
        var meModel;
        var other;
        for (ChatUserEntity participant in entity.participants) {
          if (participant.userId == GetIt.I.get<UserService>().user.id) {
            meModel = ChatUserModel(
              user: GetIt.I.get<UserService>().user,
              isMuted: participant.isMuted,
              isTyping: false,
              lastSeen: participant.lastSeen,
              displayName: "displaynmae",
            );
          } else {
            var otherUserModel = await GetIt.I.get<UserService>().getUser(
              participant.userId,
            );
            if (otherUserModel != null) {
              other = ChatUserModel(
                user: otherUserModel!,
                isMuted: participant.isMuted,
                isTyping: false,
                lastSeen: participant.lastSeen,
                displayName: "displaynmae",
              );
            } else {
              emit(ChatlistLoadingFailed());
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
                    message.id == GetIt.I.get<UserService>().user.id,
                  ),
                )
                .toList(),
            createdAt: entity.createdAt,
            title: "Chatroom",
          ),
        );
      }
      emit(ChatlistLoaded(chatModels));
    });
  }
}
