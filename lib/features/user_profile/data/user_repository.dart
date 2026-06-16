import 'package:zockblock_app/features/user_profile/data/user.dart';

abstract class UserRepository {
  Stream<bool> get onUserStateChanged;
  Future<User?> getCurrentUser();
  Future<User?> createUser(User newUser);
}
