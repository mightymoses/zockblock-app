import 'auth_session.dart';

abstract class AuthRepository {
  Stream<bool> get onAuthStateChanged;
  Future<AuthSession> login();
  Future<void> logout();
  Future<AuthSession?> getExistingSession();
}
