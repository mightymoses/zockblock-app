import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/config/env.dart';
import 'package:zockblock_app/core/network/auth_interceptor.dart';

/// Dio-Client für alle Backend-Requests, mit [AuthInterceptor] für den
/// Auth0-Bearer-Token.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(ref.watch(authInterceptorProvider));

  return dio;
});
