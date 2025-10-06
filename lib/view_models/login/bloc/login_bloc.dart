import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/models/user_credentails.dart';
import 'package:meet_christ/repositories/auth_repository.dart';
import 'package:meet_christ/view_models/auth/bloc/auth_bloc.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  final AuthBloc authBloc; // <-- injected so it can notify

  LoginBloc({required this.authRepository, required this.authBloc})
      : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LoginInit>(_onLoginInit);
  }

  void _onLoginInit(
    LoginInit event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitialized(email: event.email, password: event.password));
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final credentials = UserCredentials(
        email: event.email,
        password: event.password,
      );

      final user = await authRepository.loginWithUserCredentials(credentials);

      if (user != null) {
        // ✅ Tell AuthBloc that a user logged in
        authBloc.add(UserLoggedIn(user));
        emit(LoginSuccess(user));
      } else {
        emit(LoginFailure('Invalid credentials'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
