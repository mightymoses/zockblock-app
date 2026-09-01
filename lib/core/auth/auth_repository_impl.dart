import 'dart:async';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zockblock_app/core/auth/auth_repository.dart';
import 'package:zockblock_app/core/auth/auth_service.dart';
import 'package:zockblock_app/core/auth/auth_session.dart';

/// Stellt das [AuthRepository] bereit.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(authService);
});

// TODO(router-refresh-fix): entfällt, sobald refreshListenable steht.
final onAuthStateChangedProvider = StreamProvider<bool>((ref) {
  return ref.read(authRepositoryProvider).onAuthStateChanged;
});

/// Implementiert [AuthRepository] über [AuthService] (Auth0).
class AuthRepositoryImpl implements AuthRepository {
  /// Erstellt das Repository mit dem [AuthService], den es kapselt.
  AuthRepositoryImpl(this._authService);

  final AuthService _authService;
  final _authStatusController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get onAuthStateChanged => _authStatusController.stream;

  @override
  Future<AuthSession> login() async {
    final credentials = await _authService.login();
    final authSession = AuthSession.fromCredentials(credentials);

    _authStatusController.add(true);
    return authSession;
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
    _authStatusController.add(false);
  }

  @override
  Future<AuthSession?> getExistingSession() async {
    try {
      final credentials = await _authService.getCredentials();
      final authSession = AuthSession.fromCredentials(credentials);

      _authStatusController.add(true);
      return authSession;
    } on CredentialsManagerException catch (e) {
      if (e.isNoCredentialsFound || e.isNoRefreshTokenFound) {
        _authStatusController.add(false);
        return null;
      }
      rethrow;
    }
  }
}
