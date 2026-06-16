import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/dio/dio_provider.dart';
import 'package:zockblock_app/features/user_profile/data/user.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(dioProvider);
  return UserService(dio);
});

class UserService {
  const UserService(this._dio);

  final Dio _dio;

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/users/current');
    return User.fromJson(response.data);
  }

  Future<User> createUser(User user) async {
    final response = await _dio.post('/users/', data: user.toJson());
    return User.fromJson(response.data);
  }
}
