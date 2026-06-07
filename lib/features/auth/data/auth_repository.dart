import 'auth_user.dart';

abstract class AuthRepository {
  Stream<bool> get onAuthStateChanged;
  Future<AuthUser> login();
  Future<void> logout();
  Future<AuthUser?> getExistingSession();
}

