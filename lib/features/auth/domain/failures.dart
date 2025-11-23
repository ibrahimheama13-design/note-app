sealed class AuthFailure {
  const AuthFailure();
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure();
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure();
}

class EmailInUseFailure extends AuthFailure {
  const EmailInUseFailure();
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure();
}

class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure();
}

class UnknownFailure extends AuthFailure {
  final String? message;
  const UnknownFailure([this.message]);
}
