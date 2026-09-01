import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/network/dio_provider.dart';
import 'package:zockblock_app/features/user_profile/data/user.dart';

/// Stellt den [UserService] bereit.
final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(dioProvider);
  return UserService(dio);
});

/// Dünner Wrapper um die `/users`-Endpunkte des Backends.
class UserService {
  /// Erstellt den Service mit dem [Dio]-Client, über den er Requests schickt.
  const UserService(this._dio);

  final Dio _dio;

  /// Lädt das Profil des eingeloggten Nutzers.
  /// Wirft [DioException] mit Status 404, wenn noch kein Profil existiert.
  Future<User> getCurrentUser() async {
    final response = await _dio.get<Map<String, Object?>>('/users/current');
    return User.fromJson(response.data!);
  }

  /// Legt ein neues Nutzerprofil an.
  Future<User> createUser(User user) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/users/',
      data: user.toJson(),
    );
    return User.fromJson(response.data!);
  }
}
