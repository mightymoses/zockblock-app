import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/auth/auth_service.dart';

/// Stellt den [AuthInterceptor] für den `dioProvider` bereit.
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(ref.watch(authServiceProvider));
});

/// Hängt bei jedem Request den aktuellen Auth0-Access-Token als
/// Authorization-Header an. `AuthService.getCredentials()` prüft/erneuert
/// den Token bei Bedarf selbst - hier wird nur gelesen, nicht der globale
/// Session-State mutiert.
///
/// Als [QueuedInterceptor], damit parallele Requests sich einen laufenden
/// Token-Refresh teilen statt ihn mehrfach parallel auszulösen.
class AuthInterceptor extends QueuedInterceptor {
  /// Erstellt den Interceptor mit dem [AuthService], über den er Tokens holt.
  AuthInterceptor(this._authService);

  final AuthService _authService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final credentials = await _authService.getCredentials();
      options.headers['Authorization'] = 'Bearer ${credentials.accessToken}';
    } on CredentialsManagerException {
      // Nicht eingeloggt oder Refresh nicht möglich - Request geht ohne
      // Authorization-Header raus, Backend antwortet ggf. mit 401.
    }
    handler.next(options);
  }
}
