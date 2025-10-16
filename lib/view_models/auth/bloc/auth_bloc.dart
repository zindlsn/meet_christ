import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/repositories/auth_repository.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final UserService _userService;
  late final StreamSubscription<User?> _authSub;

  AuthBloc(this._auth, this._userService) : super(AuthInitial()) {
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        add(UserLoggedIn(user));
      } else {
        add(UserLoggedOut());
      }
    });

    on<UserLoggedIn>((event, emit) async {
      final userData = await _userService.getUser(event.user.uid);
      if (userData == null) {
        emit(Unauthenticated());
      } else {
        _userService.setLoggedInUser(userData);
        emit(Authenticated(userData));
      }
    });

    on<UserLoggedOut>((event, emit) async {
      _userService.user = UserModel.empty();
      emit(Unauthenticated());
    });
    on<ResetPasswordRequested>((event, emit) async {
    await  GetIt.I.get<AuthRepository>().sendPasswordResetEmail(email: event.email);
      emit(Unauthenticated());
    });
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
