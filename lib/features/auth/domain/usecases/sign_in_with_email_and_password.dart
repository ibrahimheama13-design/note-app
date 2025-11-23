import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../failures.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailAndPassword {
  final AuthRepository _authRepository;

  const SignInWithEmailAndPassword(this._authRepository);

  Future<Either<AuthFailure, User>> call(String email, String password) {
    return _authRepository.signInWithEmailAndPassword(email, password);
  }
}
