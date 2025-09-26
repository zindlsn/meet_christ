import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet_christ/main.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/models/user_credentails.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meet_christ/view_models/auth/cubit/auth_state.dart';
import 'package:uuid/uuid.dart';

class AuthCubit extends Cubit<AuthState> {
  final UserService userService;

  AuthCubit({
    String initialEmail = 'szindl@posteo.de',
    String initialPassword = 'Jesus1000.',
    required this.userService,
  }) : super(AuthState(email: initialEmail, password: initialPassword));

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: AuthStatus.validating));
  }

  void firstnameChanged(String value) {
    emit(state.copyWith(firstname: value, status: AuthStatus.validating));
  }
  void lastnameChanged(String value) {
    emit(state.copyWith(lastname: value, status: AuthStatus.validating));
  }

    void birthdayChanged(DateTime value) {
    emit(state.copyWith(birthday: value, status: AuthStatus.validating));
  }


  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: AuthStatus.validating));
  }

  Future<bool> isEmailAvailable(String email) async {
    var authUser = await userService.emailAvailable(email);
    if (authUser != null) passwordChanged(authUser.password);
    return authUser?.user != null;
  }

  Future<void> submit() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: "Fields cannot be empty",
        ),
      );
      return;
    }
    emit(state.copyWith(status: AuthStatus.submitting));
    try {
      await userService.signUp(
        UserCredentials(email: state.email, password: state.password),
        User(
          email: state.email,
          firstname: state.firstname,
          id: Uuid().v4(),
          birthday: state.birthday,
          lastname: state.lastname,
          isAnonym: false,
        ),
      );
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  void reset() {
    emit(AuthState());
  }
}
