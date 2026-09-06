import 'dart:async';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/config/env.dart';

/// Stellt den [AuthService] bereit.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Dünner Wrapper um das Auth0-SDK für Login, Logout und Token-Zugriff.
class AuthService {
  final _auth0 = Auth0(AppEnv.auth0Domain, AppEnv.auth0ClientId);

  /// Startet den Auth0-Login-Flow (Universal Login im Browser).
  Future<Credentials> login() async {
    final credentials = await _auth0.webAuthentication().login(
      useHTTPS: true,
      audience: AppEnv.auth0Audience,
    );
    return credentials;
  }

  /// Beendet die Auth0-Session.
  Future<void> logout() async {
    await _auth0.webAuthentication().logout(useHTTPS: true);
  }

  /// Liefert die gespeicherten Credentials, erneuert sie bei Bedarf selbst.
  /// Wirft [CredentialsManagerException], wenn keine gültige Session besteht.
  Future<Credentials> getCredentials() async {
    return _auth0.credentialsManager.credentials();
  }
}
