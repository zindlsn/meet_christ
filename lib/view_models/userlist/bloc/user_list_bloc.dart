import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/pages/chat_list_page.dart';
import 'package:meet_christ/pages/chat_page.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meta/meta.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  UserListBloc() : super(UserListInitial()) {
    on<FetchUserListEvent>((event, emit) async {
      emit(UserListLoading());
      try {
        List<SingleChatEntity> chats = await GetIt.I
            .get<ChatListRepository>()
            .fetchChats(GetIt.I.get<UserService>().user.id);
        List<ChatModel> chatModels = [];

        /*  for (var chat in chats) {
          if(chat.id == GetIt.I.get<UserService>().user.id){
            var meModel = ChatUserModel(userId: GetIt.I.get<UserService>().user, displayName: "", isMuted: false);
            var me = ChatUserModel(userId: chat.participant1, displayName: chat.participant1.displayName);
          }
          var model = ChatModel(me: me, other: chat.participant2);
          chatModels.add(chat);
        }*/

        final users = await GetIt.I.get<UserService>().fetchUsers();
        if (chats.isNotEmpty) {
          final availableNewChatPartners = users.where((user) {
            // Check if this user appears in ANY chat
            final alreadyInChat = chats.any(
              (chat) => chat.participants.any((p) => p.userId == user.id),
            );

            // Keep only users who are NOT already in any chat
            return !alreadyInChat;
          }).toList();
          emit(UserListLoaded(availableNewChatPartners));
        } else {
          emit(UserListLoaded(users));
        }
      } catch (e) {
        emit(UserListError(e.toString()));
      }
    });
  }
}
