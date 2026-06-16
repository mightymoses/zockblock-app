import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/features/auth/data/auth_session_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        await ref.read(authSessionProvider.notifier).renewSession();
        final authSessionAsyncValue = ref.read(authSessionProvider);

        authSessionAsyncValue.whenData((authSession) {
          final token = authSession?.accessToken;

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        });

        return handler.next(options);
      },
    ),
  );

  return dio;
});
