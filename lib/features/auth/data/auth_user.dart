import 'package:auth0_flutter/auth0_flutter.dart';

class AuthUser {
  final String id;
  final String? email;
  final String accessToken;

  const AuthUser({
    required this.id,
    this.email,
    required this.accessToken,
  });

  factory AuthUser.fromCredentials(Credentials credentials) {
    return AuthUser(
      id: credentials.user.sub,
      email: credentials.user.email,
      accessToken: credentials.accessToken,
    );
  }
}