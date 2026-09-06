import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:zockblock_app/core/auth/auth_service.dart';
import 'package:zockblock_app/core/logging/logger_provider.dart';

/// Stellt den [AuthInterceptor] für den `dioProvider` bereit.
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(
    ref.watch(authServiceProvider),
    ref.watch(loggerProvider),
  );
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
  AuthInterceptor(this._authService, this._logger);

  final AuthService _authService;
  final Logger _logger;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final credentials = await _authService.getCredentials();
      options.headers['Authorization'] = 'Bearer ${credentials.accessToken}';
    } on CredentialsManagerException catch (e, stackTrace) {
      // Request geht ohne Authorization-Header raus, das Backend antwortet
      // dann mit 401. Ohne Logzeile ist die Ursache dafür später nicht mehr
      // erkennbar.
      if (e.isNoCredentialsFound || e.isNoRefreshTokenFound) {
        // Schlicht nicht eingeloggt - erwartet, z.B. vor dem ersten Login.
        _logger.d('Request ohne Token: ${options.path}');
      } else {
        // Der Nutzer war eingeloggt, der Token liess sich aber nicht
        // erneuern - das ist der Fall, der später Rätsel aufgibt.
        _logger.w(
          'Token-Erneuerung fehlgeschlagen: ${options.path}',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
    handler.next(options);
  }
}
