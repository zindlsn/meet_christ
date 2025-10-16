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
  final _authRepository = GetIt.I.get<AuthRepository>();

  AuthBloc(this._auth, this._userService) : super(AuthInitial()) {
    on<UserLoggedIn>((event, emit) async {
      final userData = await _userService.getUser(event.user.uid);
      if (userData == null) {
        add(UserLoggedOut(_auth.currentUser));
        emit(Unauthenticated());
      } else {
        _userService.setLoggedInUser(userData);
        add(Authenticat(userData));
      }
    });

    on<Authenticat>((event, emit) async {
      _userService.user = event.user;
      emit(Authenticated(event.user));
    });

    on<UserLoggedOut>((event, emit) async {
      _userService.user = UserModel.empty();
      if (_auth.currentUser?.isAnonymous == true) {
        await _userService.deleteUser(_auth.currentUser!.uid);
        await _auth.currentUser?.delete();
      }
      await _auth.signOut();
      emit(Unauthenticated());
    });
    on<ResetPasswordRequested>((event, emit) async {
      await GetIt.I.get<AuthRepository>().sendPasswordResetEmail(
        email: event.email,
      );
      emit(Unauthenticated());
    });
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
