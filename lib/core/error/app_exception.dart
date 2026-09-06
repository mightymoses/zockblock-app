/// Fehler, die die App fachlich unterscheiden kann.
///
/// Bewusst klein gehalten: die UI braucht nur so viele Fälle, wie sie dem
/// Nutzer unterschiedlich erklären kann. Library-spezifische Fehler (dio,
/// Auth0) werden in `data`-nahen Schichten hierauf abgebildet, damit Schichten
/// darüber die Libraries nicht kennen müssen.
sealed class AppException implements Exception {
  /// Erstellt den Fehler, optional mit dem auslösenden [cause].
  const AppException([this.cause]);

  /// Ursprünglicher Fehler, für Logging und Crash-Reporting.
  final Object? cause;
}

/// Keine Verbindung zum Backend – offline oder Timeout.
class NetworkException extends AppException {
  /// Erstellt den Fehler.
  const NetworkException([super.cause]);
}

/// Das Backend hat mit einem Serverfehler geantwortet (5xx).
class ServerException extends AppException {
  /// Erstellt den Fehler.
  const ServerException([super.cause]);
}

/// Der Request war nicht oder nicht ausreichend authentifiziert (401/403).
class UnauthorizedException extends AppException {
  /// Erstellt den Fehler.
  const UnauthorizedException([super.cause]);
}

/// Die angefragte Ressource existiert nicht (404).
class NotFoundException extends AppException {
  /// Erstellt den Fehler.
  const NotFoundException([super.cause]);
}

/// Fehler, der sich keinem der anderen Fälle zuordnen lässt.
class UnknownException extends AppException {
  /// Erstellt den Fehler.
  const UnknownException([super.cause]);
}
