import 'package:zockblock_app/core/auth/auth_session.dart';

/// Zugriff auf Login/Logout/Session-Check über Auth0.
abstract class AuthRepository {
  /// Startet den Login-Flow, wirft bei Abbruch/Fehler.
  Future<AuthSession> login();

  /// Meldet den Nutzer ab.
  Future<void> logout();

  /// Liefert die bestehende Session, oder `null` wenn nicht eingeloggt.
  Future<AuthSession?> getExistingSession();
}
