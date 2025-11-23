import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../failures.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<AuthFailure, User>> signUpWithEmailAndPassword(
    String email,
    String password,
  );
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}
