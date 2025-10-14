part of 'chatlist_bloc.dart';

@immutable
sealed class ChatlistEvent {}

final class FetchChatListEvent extends ChatlistEvent {}
final class ChatlistUpdated extends ChatlistEvent{
  final List<SingleChatModel> chatModels;
  ChatlistUpdated({required this.chatModels});
}