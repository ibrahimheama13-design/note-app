import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures.dart';
import '../../domain/usecases/sign_in_with_email_and_password.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email_and_password.dart';

class AuthProvider extends ChangeNotifier {
  final SignInWithEmailAndPassword _signInWithEmailAndPassword;
  final SignUpWithEmailAndPassword _signUpWithEmailAndPassword;
  final SignOut _signOut;
  final FirebaseAuthRepository _authRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // StreamController to broadcast auth state changes
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  AuthProvider({
    required SignInWithEmailAndPassword signInWithEmailAndPassword,
    required SignUpWithEmailAndPassword signUpWithEmailAndPassword,
    required SignOut signOut,
    FirebaseAuthRepository? authRepository,
  }) : _signInWithEmailAndPassword = signInWithEmailAndPassword,
       _signUpWithEmailAndPassword = signUpWithEmailAndPassword,
       _signOut = signOut,
       _authRepository = authRepository ?? FirebaseAuthRepository() {
    _init();
  }

  StreamSubscription<User?>? _authSub;

  void _init() {
    // Listen to the original stream and broadcast to our controller
    _authSub = _authRepository.authStateChanges.listen(
      (user) {
        _currentUser = user;
        _isInitialized = true;
        _authStateController.add(user);
        notifyListeners();
      },
      onError: (error) {
        _authStateController.addError(error);
      },
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authStateController.close();
    super.dispose();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  /// Returns a broadcast stream that can be listened to multiple times
  /// This prevents issues with StreamBuilder recreating subscriptions
  Stream<User?> get authStateChanges => _authStateController.stream;

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _signInWithEmailAndPassword(email, password);

    result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
        _currentUser = null;
      },
      (user) {
        _errorMessage = null;
        _currentUser = user;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _signUpWithEmailAndPassword(email, password);

    result.fold(
      (failure) {
        _errorMessage = _getErrorMessage(failure);
        _currentUser = null;
      },
      (user) {
        _errorMessage = null;
        _currentUser = user;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _signOut();
    _currentUser = null;
    notifyListeners();
  }

  String getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'user-not-found':
        return 'لم يتم العثور على حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل';
      case 'operation-not-allowed':
        return 'تسجيل الدخول بالبريد الإلكتروني وكلمة المرور غير مفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  String _getErrorMessage(AuthFailure failure) {
    return switch (failure) {
      InvalidEmailFailure() => 'البريد الإلكتروني غير صالح',
      WeakPasswordFailure() => 'كلمة المرور ضعيفة جداً',
      EmailInUseFailure() => 'هذا البريد الإلكتروني مستخدم بالفعل',
      UserNotFoundFailure() => 'لم يتم العثور على حساب بهذا البريد الإلكتروني',
      WrongPasswordFailure() => 'كلمة المرور غير صحيحة',
      UnknownFailure(:final message) => message ?? 'حدث خطأ غير متوقع',
    };
  }
}
