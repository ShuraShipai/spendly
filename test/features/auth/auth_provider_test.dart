import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';

import 'package:spendly/features/auth/models/app_user.dart';
import 'package:spendly/features/auth/providers/auth_provider.dart';
import 'package:spendly/features/auth/services/auth_service.dart';
import 'package:spendly/features/auth/services/user_firestore_service.dart';

void main() {
  group('AuthProvider', () {
    test('deletes Firebase Auth account before deleting app data', () async {
      final calls = <String>[];
      final authService = _FakeAuthService(
        onDeleteCurrentUser: () async => calls.add('auth-delete'),
      );
      final userFirestoreService = _FakeUserFirestoreService(
        getUserHandler: (_) async =>
            const AppUser(uid: 'user-1', email: 'user@example.com'),
        deleteUserHandler: (_) async => calls.add('firestore-delete'),
      );
      final provider = AuthProvider(
        authService: authService,
        userFirestoreService: userFirestoreService,
        deleteUserData: (_) async => calls.add('app-data-delete'),
      );
      addTearDown(provider.dispose);

      authService.emit(
        _FakeFirebaseUser(uid: 'user-1', email: 'user@example.com'),
      );
      await _flushMicrotasks();

      await provider.deleteAccount();

      expect(calls, ['auth-delete', 'app-data-delete', 'firestore-delete']);
    });

    test('does not delete app data when Firebase Auth delete fails', () async {
      final calls = <String>[];
      final authService = _FakeAuthService(
        onDeleteCurrentUser: () async {
          calls.add('auth-delete');
          throw firebase_auth.FirebaseAuthException(
            code: 'requires-recent-login',
          );
        },
      );
      final userFirestoreService = _FakeUserFirestoreService(
        getUserHandler: (_) async =>
            const AppUser(uid: 'user-1', email: 'user@example.com'),
        deleteUserHandler: (_) async => calls.add('firestore-delete'),
      );
      final provider = AuthProvider(
        authService: authService,
        userFirestoreService: userFirestoreService,
        deleteUserData: (_) async => calls.add('app-data-delete'),
      );
      addTearDown(provider.dispose);

      authService.emit(
        _FakeFirebaseUser(uid: 'user-1', email: 'user@example.com'),
      );
      await _flushMicrotasks();

      await provider.deleteAccount();

      expect(calls, ['auth-delete']);
      expect(
        provider.errorMessage,
        'Sign in again before deleting your account.',
      );
    });

    test(
      'falls back to Firebase user when Firestore auth mapping fails',
      () async {
        final authService = _FakeAuthService();
        final provider = AuthProvider(
          authService: authService,
          userFirestoreService: _FakeUserFirestoreService(
            getUserHandler: (_) async =>
                throw StateError('Firestore unavailable'),
          ),
        );
        addTearDown(provider.dispose);

        authService.emit(
          _FakeFirebaseUser(
            uid: 'user-1',
            email: 'user@example.com',
            displayName: 'Pat',
            photoUrl: 'https://example.com/pat.png',
            emailVerified: false,
          ),
        );
        await _flushMicrotasks();

        expect(provider.status, AuthStatus.authenticated);
        expect(provider.user?.uid, 'user-1');
        expect(provider.user?.email, 'user@example.com');
        expect(provider.user?.displayName, 'Pat');
        expect(provider.user?.photoUrl, 'https://example.com/pat.png');
        expect(provider.isEmailVerified, isFalse);
      },
    );

    test('ignores stale async auth mappings', () async {
      final firstUser = Completer<AppUser?>();
      final secondUser = Completer<AppUser?>();
      final authService = _FakeAuthService();
      final provider = AuthProvider(
        authService: authService,
        userFirestoreService: _FakeUserFirestoreService(
          getUserHandler: (uid) {
            return uid == 'first' ? firstUser.future : secondUser.future;
          },
        ),
      );
      addTearDown(provider.dispose);

      authService
        ..emit(_FakeFirebaseUser(uid: 'first', email: 'first@example.com'))
        ..emit(_FakeFirebaseUser(uid: 'second', email: 'second@example.com'));
      secondUser.complete(
        const AppUser(
          uid: 'second',
          email: 'second-from-firestore@example.com',
        ),
      );
      await _flushMicrotasks();
      firstUser.complete(
        const AppUser(uid: 'first', email: 'first-from-firestore@example.com'),
      );
      await _flushMicrotasks();

      expect(provider.status, AuthStatus.authenticated);
      expect(provider.user?.uid, 'second');
      expect(provider.user?.email, 'second-from-firestore@example.com');
    });
  });
}

Future<void> _flushMicrotasks() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.onDeleteCurrentUser});

  final Future<void> Function()? onDeleteCurrentUser;
  final _authStateController =
      StreamController<firebase_auth.User?>.broadcast();

  void emit(firebase_auth.User? user) {
    _authStateController.add(user);
  }

  @override
  Stream<firebase_auth.User?> authStateChanges() {
    return _authStateController.stream;
  }

  @override
  Future<void> deleteCurrentUser() async {
    await onDeleteCurrentUser?.call();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserFirestoreService implements UserFirestoreService {
  _FakeUserFirestoreService({
    required this._getUserHandler,
    this._deleteUserHandler,
  });

  final Future<AppUser?> Function(String uid) _getUserHandler;
  final Future<void> Function(String uid)? _deleteUserHandler;

  @override
  Future<AppUser?> getUser(String uid) {
    return _getUserHandler(uid);
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _deleteUserHandler?.call(uid);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseUser implements firebase_auth.User {
  _FakeFirebaseUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = true,
  });

  @override
  final String uid;

  @override
  final String? email;

  @override
  final String? displayName;

  final String? photoUrl;

  @override
  final bool emailVerified;

  @override
  String? get photoURL => photoUrl;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
