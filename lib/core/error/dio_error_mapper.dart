import 'package:dio/dio.dart';
import 'package:zockblock_app/core/error/app_exception.dart';

/// Bildet eine [DioException] auf die passende [AppException] ab.
///
/// Wird im Service aufgerufen, nicht in einem Interceptor: dio verpackt in
/// `onError` jeden Fehler wieder in eine [DioException], der Typ ließe sich
/// dort also gar nicht ersetzen.
AppException mapDioException(DioException e) {
  final status = e.response?.statusCode;

  if (status != null) {
    return switch (status) {
      401 || 403 => UnauthorizedException(e),
      404 => NotFoundException(e),
      >= 500 => ServerException(e),
      _ => UnknownException(e),
    };
  }

  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => NetworkException(e),
    _ => UnknownException(e),
  };
}
