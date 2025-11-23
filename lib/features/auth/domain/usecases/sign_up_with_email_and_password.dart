import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../failures.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailAndPassword {
  final AuthRepository _authRepository;

  const SignUpWithEmailAndPassword(this._authRepository);

  Future<Either<AuthFailure, User>> call(String email, String password) {
    return _authRepository.signUpWithEmailAndPassword(email, password);
  }
}
