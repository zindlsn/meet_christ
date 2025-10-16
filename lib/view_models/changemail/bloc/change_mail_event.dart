part of 'change_mail_bloc.dart';

@immutable
sealed class ChangeMailEvent {}

final class ChangeMailRequested  extends ChangeMailEvent{
  final String oldEmail;
  final String newEmail;
  final String password;

  ChangeMailRequested({required this.oldEmail, required this.newEmail, required this.password});

}
