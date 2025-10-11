part of 'chat_page_bloc.dart';

@immutable
sealed class ChatPageState {}

final class ChatPageInitial extends ChatPageState {}

final class ChatLoaded extends ChatPageState {
  final SingleChatModel chat;
  ChatLoaded({required this.chat});
}

final class ChatLoadedFailed extends ChatPageState {}

final class ChatLoading extends ChatPageState {}

final class ChatMessageSentSucces extends ChatPageState{}