// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_firestore_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    required UserFirestoreService userFirestoreService,
  }) : _authService = authService,
       _userFirestoreService = userFirestoreService {
    _authSubscription = _authService.authStateChanges().listen(
      _setFirebaseUser,
    );
  }

  final AuthService _authService;
  final UserFirestoreService _userFirestoreService;

  StreamSubscription<firebase_auth.User?>? _authSubscription;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _runAuthTask(() async {
      final credential = await _authService.signUpWithEmail(
        email: email.trim(),
        password: password,
        displayName: displayName,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw firebase_auth.FirebaseAuthException(code: 'user-not-found');
      }

      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? email.trim(),
        displayName: displayName?.trim().isEmpty ?? true
            ? null
            : displayName?.trim(),
      );
      await _userFirestoreService.createUser(appUser);
      _user = appUser;
      _status = AuthStatus.authenticated;
    });
  }

  Future<void> login({required String email, required String password}) async {
    await _runAuthTask(() async {
      final credential = await _authService.signInWithEmail(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw firebase_auth.FirebaseAuthException(code: 'user-not-found');
      }

      _user =
          await _userFirestoreService.getUser(firebaseUser.uid) ??
          AppUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? email.trim(),
            displayName: firebaseUser.displayName,
          );
      _status = AuthStatus.authenticated;
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _runAuthTask(() {
      return _authService.sendPasswordResetEmail(email.trim());
    });
  }

  Future<void> resetPassword({
    required String code,
    required String newPassword,
  }) async {
    await _runAuthTask(() {
      return _authService.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    });
  }

  Future<void> logout() async {
    await _runAuthTask(_authService.signOut);
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _setFirebaseUser(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _user =
        await _userFirestoreService.getUser(firebaseUser.uid) ??
        AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
        );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> _runAuthTask(Future<void> Function() task) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await task();
    } on firebase_auth.FirebaseAuthException catch (error) {
      _errorMessage = _messageForAuthError(error);
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  String _messageForAuthError(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'network-request-failed':
        return 'Check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'expired-action-code':
        return 'This reset link has expired.';
      case 'invalid-action-code':
        return 'This reset link is invalid.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
