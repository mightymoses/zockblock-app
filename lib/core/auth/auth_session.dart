import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// Eingeloggte Auth0-Session: externe Nutzer-ID + Access-Token.
@freezed
abstract class AuthSession with _$AuthSession {
  /// Erstellt eine [AuthSession] direkt aus ihren Feldern.
  const factory AuthSession({
    required String externalAuthId,
    required String accessToken,
  }) = _AuthSession;

  /// Deserialisiert eine [AuthSession] aus JSON.
  factory AuthSession.fromJson(Map<String, Object?> json) =>
      _$AuthSessionFromJson(json);

  /// Baut eine [AuthSession] aus Auth0-[Credentials].
  factory AuthSession.fromCredentials(Credentials credentials) {
    return AuthSession(
      externalAuthId: credentials.user.sub,
      accessToken: credentials.accessToken,
    );
  }
}
