import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

import '../../domain/entities/user.dart';
import '../../domain/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser == null
          ? null
          : UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  Future<Either<AuthFailure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return left(const UnknownFailure('User is null after sign in'));
      }

      return right(UserModel.fromFirebaseUser(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return left(const InvalidEmailFailure());
        case 'user-not-found':
          return left(const UserNotFoundFailure());
        case 'wrong-password':
          return left(const WrongPasswordFailure());
        default:
          return left(UnknownFailure(e.message));
      }
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, User>> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return left(const UnknownFailure('User is null after sign up'));
      }

      return right(UserModel.fromFirebaseUser(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return left(const InvalidEmailFailure());
        case 'weak-password':
          return left(const WeakPasswordFailure());
        case 'email-already-in-use':
          return left(const EmailInUseFailure());
        default:
          return left(UnknownFailure(e.message));
      }
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
