import 'auth_repository.dart';
import 'auth_service.dart';
import 'auth_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);
  
  @override
  Future<AuthUser> login() async {
    final credentials = await _authService.login();
    return AuthUser.fromCredentials(credentials);
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<AuthUser?> getExistingSession() async {
    try {
      final hasValid = await _authService.hasValidCredentials();
      if (!hasValid) return null;
      final credentials = await _authService.getCredentials();
      if (credentials == null) return null;
      return AuthUser.fromCredentials(credentials);
    } catch (e) {
      return null;
    }
  }
}