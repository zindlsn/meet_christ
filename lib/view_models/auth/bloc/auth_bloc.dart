import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/repositories/auth_repository.dart';
import 'package:meet_christ/services/localstorage_service.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final UserService _userService;

  AuthBloc(this._auth, this._userService) : super(AuthInitial()) {
    on<UserLoggedIn>((event, emit) async {
      final userData = await _userService.getUser(event.user.uid);
      if (userData == null) {
        add(UserLoggedOut(_auth.currentUser));
        emit(Unauthenticated());
      } else {
        LocalStorageService.saveData<String?>(
          LocalStorageKeys.loggedInUserId,
          userData.id,
        );
        _userService.setLoggedInUser(userData);
        emit(Authenticated(userData));
      }
    });

    on<UserLoggedOut>((event, emit) async {
      LocalStorageService.saveData<String?>(
        LocalStorageKeys.loggedInUserId,
        null,
      );
      _userService.user = UserModel.empty();
      if (_auth.currentUser?.isAnonymous == true) {
        await _userService.deleteUser(_auth.currentUser!.uid);
        await _auth.currentUser?.delete();
      }
      await _auth.signOut();
      LocalStorageService.saveData<bool>(LocalStorageKeys.rememberMe, false);
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
    return super.close();
  }
}
