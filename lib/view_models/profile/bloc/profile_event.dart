part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class StartEditingProfile extends ProfileEvent {}

final class LoadProfile extends ProfileEvent {}