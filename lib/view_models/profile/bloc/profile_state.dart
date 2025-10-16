part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final UserModel user;
  final bool isEditing;

  ProfileLoaded({required this.user, required this.isEditing});
}
