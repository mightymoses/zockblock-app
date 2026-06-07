import 'dart:async';

import 'package:auth0_flutter/auth0_flutter.dart';

class AuthService {
  final _auth0 = Auth0(
    'zockblock.eu.auth0.com',
    'saaES4mot3pMpTKt2ZHB9c1rDQrvPziy',
  );

  final _statusController = StreamController<bool>.broadcast();
  Stream<bool> get authStateChanges => _statusController.stream;

  Future<Credentials> login() async {
    final credentials = await _auth0.webAuthentication().login(useHTTPS: true);
    _statusController.add(true);
    return credentials;
  }

  Future<void> logout() async {
    await _auth0.webAuthentication().logout(useHTTPS: true);
    _statusController.add(false);
  }

  Future<bool> hasValidCredentials() async {
    final hasValidCredentials = await _auth0.credentialsManager
        .hasValidCredentials();
    _statusController.add(hasValidCredentials);
    return hasValidCredentials;
  }

  Future<Credentials?> getCredentials() async {
    return await _auth0.credentialsManager.credentials();
  }
}

