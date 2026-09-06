import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zockblock_app/core/error/app_exception.dart';
import 'package:zockblock_app/core/error/dio_error_mapper.dart';

DioException _withStatus(int statusCode) {
  final options = RequestOptions(path: '/users/current');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<void>(requestOptions: options, statusCode: statusCode),
  );
}

DioException _withType(DioExceptionType type) {
  return DioException(
    requestOptions: RequestOptions(path: '/users/current'),
    type: type,
  );
}

void main() {
  group('mapDioException nach Statuscode', () {
    const cases = <int, Type>{
      401: UnauthorizedException,
      403: UnauthorizedException,
      404: NotFoundException,
      500: ServerException,
      503: ServerException,
      // Kein Fall, den die UI unterschiedlich erklären könnte.
      418: UnknownException,
    };

    for (final entry in cases.entries) {
      test('${entry.key} wird zu ${entry.value}', () {
        final mapped = mapDioException(_withStatus(entry.key));

        expect(mapped, isA<AppException>());
        expect(mapped.runtimeType, entry.value);
      });
    }
  });

  group('mapDioException ohne Antwort', () {
    const cases = <DioExceptionType, Type>{
      DioExceptionType.connectionTimeout: NetworkException,
      DioExceptionType.sendTimeout: NetworkException,
      DioExceptionType.receiveTimeout: NetworkException,
      DioExceptionType.connectionError: NetworkException,
      DioExceptionType.cancel: UnknownException,
      DioExceptionType.badCertificate: UnknownException,
    };

    for (final entry in cases.entries) {
      test('${entry.key.name} wird zu ${entry.value}', () {
        expect(mapDioException(_withType(entry.key)).runtimeType, entry.value);
      });
    }
  });

  test('behält den ursprünglichen Fehler als cause', () {
    final dioException = _withStatus(500);

    expect(mapDioException(dioException).cause, same(dioException));
  });

  test('Statuscode schlägt den Typ – ein 404 ist kein Netzwerkfehler', () {
    final options = RequestOptions(path: '/users/current');
    final dioException = DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      response: Response<void>(requestOptions: options, statusCode: 404),
    );

    expect(mapDioException(dioException), isA<NotFoundException>());
  });
}
