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

/// Implementiert [AuthRepository] über [AuthService] (Auth0).
class AuthRepositoryImpl implements AuthRepository {
  /// Erstellt das Repository mit dem [AuthService], den es kapselt.
  AuthRepositoryImpl(this._authService);

  final AuthService _authService;

  @override
  Future<AuthSession> login() async {
    final credentials = await _authService.login();
    return AuthSession.fromCredentials(credentials);
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<AuthSession?> getExistingSession() async {
    try {
      final credentials = await _authService.getCredentials();
      return AuthSession.fromCredentials(credentials);
    } on CredentialsManagerException catch (e) {
      if (e.isNoCredentialsFound || e.isNoRefreshTokenFound) {
        return null;
      }
      rethrow;
    }
  }
}
