part of 'chatlist_bloc.dart';

@immutable
sealed class ChatlistState {}

final class ChatlistInitial extends ChatlistState {}

final class ChatlistLoading extends ChatlistState {}

final class ChatlistLoaded extends ChatlistState {
  final List<SingleChatModel> chats;

  ChatlistLoaded(this.chats);
}

final class ChatlistLoadingFailed extends ChatlistState {}
