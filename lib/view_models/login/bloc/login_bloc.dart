import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/models/user_credentails.dart';
import 'package:meet_christ/repositories/auth_repository.dart';
import 'package:meet_christ/services/localstorage_service.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:meet_christ/view_models/auth/bloc/auth_bloc.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  final AuthBloc authBloc;
  final UserService userService;
  final LocalStorageService localStorageService = LocalStorageService();

  LoginBloc({
    required this.authRepository,
    required this.authBloc,
    required this.userService,
  }) : super(LoginInitial()) {
    on<AutoLoginRequested>(_onAutoLoginRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LoginInit>(_onLoginInit);
    on<LoginWithoutAccountRequested>((event, emit) async {
      emit(LoginLoading());
      try {
        final anonymUser = await authRepository.signInAnonymously();
        if (anonymUser.isAnonymous) {
          final user = UserModel(
            id: anonymUser.uid,
            email: "",
            firstname: getRandomBibleName(),
            lastname: getRandomBibleName(),
            isAnonym: true,
          );
          await userService.createUser(user);
          authBloc.add(UserLoggedIn(anonymUser));
          emit(LoginSuccess(anonymUser));
        } else {
          emit(LoginFailure('Invalid credentials'));
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
    on<RememberMeChanged>(_onRememberMeChanged);
  }

  void _onLoginInit(LoginInit event, Emitter<LoginState> emit) async {
    var rememberMe = await localStorageService.getFromDisk<bool>(
      LocalStorageKeys.rememberMe,
    );
    emit(
      LoginInitialized(
        email: event.email,
        password: event.password,
        rememberMe: rememberMe ?? false,
      ),
    );
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

      if (user == null) {
        emit(LoginFailure('Invalid credentials'));
        return;
      }

      if (!user.emailVerified) {
        emit(LoginFailure('Please verify your email before login.'));
        return;
      }

      if (await userService.getUser(user.uid) == null) {
        final firstName = await localStorageService.getFromDisk<String>(
          LocalStorageKeys.firstName,
        );
        final lastName = await localStorageService.getFromDisk<String>(
          LocalStorageKeys.lastName,
        );

        final birthDate = await localStorageService.getDateTimeFromDisk(
          LocalStorageKeys.birthDate,
        );

        final newUser = UserModel(
          id: user.uid,
          email: user.email!,
          firstname: user.displayName ?? firstName ?? "",
          lastname: lastName ?? "",
          isAnonym: false,
          birthday: birthDate,
        );

        await userService.createUser(newUser);
      }

      if (event.rememberMe) {
        await LocalStorageService.saveData<String>(
          LocalStorageKeys.email,
          event.email,
        );
        await LocalStorageService.saveData<String>(
          LocalStorageKeys.password,
          event.password,
        );
      }

      authBloc.add(UserLoggedIn(user));
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onAutoLoginRequested(
    AutoLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    try {
      var email = await localStorageService.getFromDisk<String>(
        LocalStorageKeys.email,
      );
      var password = await localStorageService.getFromDisk<String>(
        LocalStorageKeys.password,
      );

      if (email == null || password == null) {
        email = "";
        password = "";
      }
      final credentials = UserCredentials(email: email!, password: password!);
      final user = await authRepository.loginWithUserCredentials(credentials);

      if (user == null) {
        emit(LoginInitialized(email: "", password: "", rememberMe: false));
        return;
      }

      if (!user.emailVerified) {
        emit(LoginFailure('Please verify your email before login.'));
        return;
      }
      authBloc.add(UserLoggedIn(user));
      emit(LoginSuccess(user));
    } catch (e) {
      emit(
        LoginInitialized(
          email: "stefan.zindl@outlook.de",
          password: "Jesus10001.",
          rememberMe: false,
        ),
      );
    }
  }

  Future<void> _onRememberMeChanged(
    RememberMeChanged event,
    Emitter<LoginState> emit,
  ) async {
    LocalStorageService.saveData<bool?>(
      LocalStorageKeys.rememberMe,
      event.rememberMe,
    );
    await localStorageService.getFromDisk<bool?>(LocalStorageKeys.rememberMe);
    emit(
      LoginInitialized(
        email: state is LoginInitialized
            ? (state as LoginInitialized).email
            : "",
        password: state is LoginInitialized
            ? (state as LoginInitialized).password
            : "",
        rememberMe: event.rememberMe,
      ),
    );
  }
}

String getRandomBibleName() {
  return bibleNames[random.nextInt(bibleNames.length)];
}

final bibleNames = [
  // Old Testament
  "Adam",
  "Eve",
  "Noah",
  "Abraham",
  "Sarah",
  "Isaac",
  "Rebekah",
  "Jacob",
  "Rachel",
  "Leah",
  "Joseph",
  "Moses",
  "Aaron",
  "Miriam",
  "Joshua",
  "Caleb",
  "Samuel",
  "David",
  "Jonathan",
  "Solomon",
  "Elijah",
  "Elisha",
  "Isaiah",
  "Jeremiah",
  "Ezekiel",
  "Daniel",
  "Hosea",
  "Joel",
  "Amos",
  "Obadiah",
  "Jonah",
  "Micah",
  "Nahum",
  "Habakkuk",
  "Zephaniah",
  "Haggai",
  "Zechariah",
  "Malachi",
  "Job",
  "Esther",
  "Ruth",
  "Boaz",
  "Gideon",
  "Deborah",
  "Samson",
  "Delilah",
  "Saul",
  "Rehoboam",
  "Jeroboam",
  "Hezekiah",
  "Josiah",
  "Ezra",
  "Nehemiah",
  "Esther",
  "Mordecai",

  // New Testament
  "Mary",
  "Joseph",
  "Jesus",
  "John",
  "Peter",
  "Paul",
  "James",
  "Andrew",
  "Philip",
  "Bartholomew",
  "Thomas",
  "Matthew",
  "Simon",
  "Thaddaeus",
  "Judas",
  "Barnabas",
  "Timothy",
  "Titus",
  "Silas",
  "Lydia",
  "Priscilla",
  "Aquila",
  "Apollos",
  "Stephen",
  "Philip",
  "Cornelius",
  "Luke",
  "Mark",

  // Extra Biblical figures
  "Herod",
  "Pilate",
  "Caiaphas",
  "Nicodemus",
  "Zacchaeus",
  "Martha",
  "Mary Magdalene",
  "Elizabeth", "Zechariah", "Anna", "Simeon",
];

final random = Random();
