import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/models/user_credentails.dart';
import 'package:meet_christ/repositories/auth_repository.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meet_christ/view_models/auth/bloc/auth_bloc.dart';
import 'package:meta/meta.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthRepository authRepository;
  final UserService userService;
  final AuthBloc authBloc;

  SignupBloc({
    required this.authRepository,
    required this.userService,
    required this.authBloc,
  }) : super(const SignupInitial()) {
    on<InitSignup>((event, emit) {
      emit(
        SignupDataUpdated(
          email: event.email,
          password: '',
          firstname: '',
          lastname: '',
          birthday: null,
        ),
      );
    });
    on<SignupEmailUpdated>(_onEmailUpdated);
    on<SignupPasswordUpdated>(_onPasswordUpdated);
    on<SignupNameUpdated>(_onNameUpdated);
    on<SignupBirthdayUpdated>(_onBirthdayUpdated);
    on<SignupRequested>(_onSignupRequested);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
  }

  void _onEmailUpdated(SignupEmailUpdated event, Emitter<SignupState> emit) {
    emit(
      SignupDataUpdated(
        email: event.email,
        password: state.password,
        firstname: state.firstname,
        lastname: state.lastname,
        birthday: state.birthday,
      ),
    );
  }

  void _onPasswordUpdated(
    SignupPasswordUpdated event,
    Emitter<SignupState> emit,
  ) {
    emit(
      SignupDataUpdated(
        email: state.email,
        password: event.password,
        firstname: state.firstname,
        lastname: state.lastname,
        birthday: state.birthday,
      ),
    );
  }

  void _onNameUpdated(SignupNameUpdated event, Emitter<SignupState> emit) {
    emit(
      SignupDataUpdated(
        email: state.email,
        password: state.password,
        firstname: event.firstname,
        lastname: event.lastname,
        birthday: state.birthday,
      ),
    );
  }

  void _onBirthdayUpdated(
    SignupBirthdayUpdated event,
    Emitter<SignupState> emit,
  ) {
    emit(
      SignupDataUpdated(
        email: state.email,
        password: state.password,
        firstname: state.firstname,
        lastname: state.lastname,
        birthday: event.birthday,
      ),
    );
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<SignupState> emit,
  ) async {
    emit(
      SignupLoading(
        email: state.email,
        password: state.password,
        firstname: state.firstname,
        lastname: state.lastname,
        birthday: state.birthday,
      ),
    );

    try {
      final credentials = UserCredentials(
        email: state.email,
        password: state.password,
      );

      final userCredential = await authRepository.signupWithUserCredentials(
        credentials,
      );

      final user = UserModel(
        id: userCredential.uid,
        email: state.email,
        firstname: state.firstname,
        lastname: state.lastname,
        birthday: state.birthday,
        isAnonym: false,
      );
      await userService.createUser(user);
      emit(
        SignupSuccess(
          email: state.email,
          password: state.password,
          firstname: state.firstname,
          lastname: state.lastname,
          birthday: state.birthday,
        ),
      );

      authBloc.add(UserLoggedIn(userCredential));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-not-verified') {
        emit(SignupFailure("Verify your email."));
      }
    } catch (e) {
      emit(SignupFailure(e.toString()));
    }
  }

  Future<bool> _onVerifyEmailRequested(
    VerifyEmailRequested event,
    Emitter<SignupState> emit,
  ) async{
    emit(EmailLoading());
    await Future.delayed(Duration(seconds: 10));
    var authenticated =  authRepository
        .emailIsAvailable(event.email)
        .then((authUser) {
          if (authUser == null) {
            return true; // Email is available
          } else {
            return false; // Email is already in use
          }
        })
        .catchError((error) {
          // Handle any errors that occur during the check
          return false; // Assume email is not available on error
        });
    emit(EmailLoaded());
    return authenticated;
  }
}
