import 'package:zockblock_app/features/user_profile/data/user.dart';

/// Zugriff auf das Nutzerprofil im Backend.
abstract class UserRepository {
  // TODO(router-refresh-fix): entfällt, sobald refreshListenable steht.
  Stream<bool> get onUserStateChanged;

  /// Lädt das Profil des eingeloggten Nutzers, `null` wenn noch keins
  /// existiert (Backend antwortet mit 404).
  Future<User?> getCurrentUser();

  /// Legt ein neues Nutzerprofil an, wirft bei Fehlschlag.
  Future<User> createUser(User newUser);
}
