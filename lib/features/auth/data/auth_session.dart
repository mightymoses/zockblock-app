import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String externalAuthId,
    required String accessToken,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, Object?> json) =>
      _$AuthSessionFromJson(json);

  factory AuthSession.fromCredentials(Credentials credentials) {
    return AuthSession(
      externalAuthId: credentials.user.sub,
      accessToken: credentials.accessToken,
    );
  }
}
