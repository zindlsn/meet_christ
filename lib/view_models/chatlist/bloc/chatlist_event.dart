part of 'chatlist_bloc.dart';

@immutable
sealed class ChatlistEvent {}

final class FetchChatListEvent extends ChatlistEvent {}