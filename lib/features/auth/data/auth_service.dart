import 'package:auth0_flutter/auth0_flutter.dart';

class AuthService {
  final auth0 = Auth0('zockblock.eu.auth0.com', 'saaES4mot3pMpTKt2ZHB9c1rDQrvPziy');

  Future<Credentials> login() async {
    final credentials = await auth0.webAuthentication().login(useHTTPS: true);
    return credentials;
  }

  Future<void> logout() async {
    await auth0.webAuthentication().logout(useHTTPS: true);
  }
}