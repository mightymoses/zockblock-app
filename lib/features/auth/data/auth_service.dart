import 'dart:async';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final _auth0 = Auth0(
    'zockblock.eu.auth0.com',
    'saaES4mot3pMpTKt2ZHB9c1rDQrvPziy',
  );

  Future<Credentials> login() async {
    final credentials = await _auth0.webAuthentication().login(
      useHTTPS: true,
      audience: 'https://zockblock.net',
    );
    return credentials;
  }

  Future<void> logout() async {
    await _auth0.webAuthentication().logout(useHTTPS: true);
  }

  Future<bool> hasValidCredentials() async {
    return await _auth0.credentialsManager.hasValidCredentials();
  }

  Future<Credentials> getCredentials() async {
    return await _auth0.credentialsManager.credentials();
  }
}
