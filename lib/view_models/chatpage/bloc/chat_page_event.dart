part of 'chat_page_bloc.dart';

@immutable
sealed class ChatPageEvent {}

final class LoadChat extends ChatPageEvent {
  final UserModel chatPartner;
  LoadChat({required this.chatPartner});
}

final class StartNewChat extends ChatPageEvent {
  final UserModel chatPartner;
  final ChatMessageModel firstMessageModel;
  StartNewChat({required this.chatPartner, required this.firstMessageModel});
}

final class SendMessageEvent extends ChatPageEvent {
  final String message;
  SendMessageEvent(this.message);
}

class LoadChatPartner extends ChatPageEvent {
  final String partnerId;
  LoadChatPartner(this.partnerId);
}

class StartChat extends ChatPageEvent {
  final UserModel other;
  final bool isNewChat;
  final String? chatId;
  StartChat(this.other, this.chatId, {this.isNewChat = false});
}

class SendMessage extends ChatPageEvent {
  final String text;
  SendMessage(this.text);
}
