part of 'sign_up_bloc.dart';

@immutable
abstract class SignupState {
  final String email;
  final String password;
  final String firstname;
  final String lastname;
  final DateTime? birthday;

  /// General error message (e.g., server or API error)
  final String? error;

  /// Optional field-level validation errors
  /// Example: {'email': 'Invalid email format'}
  final Map<String, String>? fieldErrors;

  const SignupState({
    this.email = '',
    this.password = '',
    this.firstname = '',
    this.lastname = '',
    this.birthday,
    this.error,
    this.fieldErrors,
  });
}

class SignupInitial extends SignupState {
  const SignupInitial() : super();
}

class SignupLoading extends SignupState {
  const SignupLoading({
    super.email,
    super.password,
    super.firstname,
    super.lastname,
    super.birthday,
    super.error,
    super.fieldErrors,
  });
}

class SignupSuccess extends SignupState {
  const SignupSuccess({
    super.email,
    super.password,
    super.firstname,
    super.lastname,
    super.birthday,
    super.error,
    super.fieldErrors,
  });
}

class SignupFailure extends SignupState {
  final String message;

  const SignupFailure(
    this.message, {
    super.email,
    super.password,
    super.firstname,
    super.lastname,
    super.birthday,
    super.fieldErrors,
  }) : super(error: message);
}

class SignupDataUpdated extends SignupState {
  const SignupDataUpdated({
    super.email,
    super.password,
    super.firstname,
    super.lastname,
    super.birthday,
    super.error,
    super.fieldErrors,
  });
}
