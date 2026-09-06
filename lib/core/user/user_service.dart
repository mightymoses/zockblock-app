import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/error/dio_error_mapper.dart';
import 'package:zockblock_app/core/network/dio_provider.dart';
import 'package:zockblock_app/core/user/user.dart';

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
  /// Wirft `NotFoundException`, wenn noch kein Profil existiert.
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, Object?>>('/users/current');
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Legt ein neues Nutzerprofil an.
  Future<User> createUser(User user) async {
    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/users/',
        data: user.toJson(),
      );
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
