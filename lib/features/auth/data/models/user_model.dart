import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.id, required super.email, super.displayName});

  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    final email = firebaseUser.email ?? '';
    final displayName =
        firebaseUser.displayName ??
        (email.isNotEmpty ? email.split('@').first : null);
    return UserModel(
      id: firebaseUser.uid,
      email: email,
      displayName: displayName,
    );
  }
}
