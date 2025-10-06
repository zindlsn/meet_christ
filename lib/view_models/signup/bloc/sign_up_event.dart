part of 'sign_up_bloc.dart';

@immutable
abstract class SignupEvent {}

class InitSignup extends SignupEvent {
  InitSignup();
}

class SignupRequested extends SignupEvent {}

class SignupEmailUpdated extends SignupEvent {
  final String email;
  SignupEmailUpdated(this.email);
}

class SignupPasswordUpdated extends SignupEvent {
  final String password;
  SignupPasswordUpdated(this.password);
}

class SignupNameUpdated extends SignupEvent {
  final String firstname;
  final String lastname;
  SignupNameUpdated(this.firstname, this.lastname);
}

class SignupBirthdayUpdated extends SignupEvent {
  final DateTime birthday;
  SignupBirthdayUpdated(this.birthday);
}
