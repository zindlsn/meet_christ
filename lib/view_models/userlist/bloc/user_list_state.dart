part of 'user_list_bloc.dart';

@immutable
sealed class UserListState {}

final class UserListInitial extends UserListState {}

final class UserListLoading extends UserListState {}

final class UserListLoaded extends UserListState {
  final List<UserModel> users;

  UserListLoaded(this.users);
}

final class UserListError extends UserListState {
  final String message;

  UserListError(this.message);
}
