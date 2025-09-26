class AuthState {
  final String email;
  final String password;
  final AuthStatus status;
  DateTime? birthday;
  final String error;
  final String firstname;
  final String lastname;

  AuthState({
    this.email = '',
    this.password = '',
    this.status = AuthStatus.idle,
    this.birthday,
    this.error = '',
    this.firstname = "",
    this.lastname = "",
  });

  AuthState copyWith({
    String? email,
    String? password,
    AuthStatus? status,
    String? error,
    DateTime? birthday,
    String? firstname,
    String? lastname
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      error: error ?? this.error,
      birthday: birthday ?? this.birthday,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname
    );
  }
}

enum AuthStatus { idle, validating, submitting, success, error }
