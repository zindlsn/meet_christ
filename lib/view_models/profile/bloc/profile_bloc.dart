import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfilePageBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfilePageBloc() : super(ProfileInitial()) {
    on<StartEditingProfile>((event, emit) {
      emit(
        ProfileLoaded(user: GetIt.I.get<UserService>().user, isEditing: true),
      );
    });

    on<LoadProfile>((event, emit) {
      emit(
        ProfileLoaded(user: GetIt.I.get<UserService>().user, isEditing: false),
      );
    });
  }
}
