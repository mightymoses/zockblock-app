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
      // Grosszuegig, weil das Backend auf Render nach Leerlauf herunter-
      // faehrt: der erste Request danach wartet auf den Kaltstart.
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(ref.watch(authInterceptorProvider));

  return dio;
});
