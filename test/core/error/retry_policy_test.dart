import 'package:flutter_test/flutter_test.dart';
import 'package:zockblock_app/core/error/app_exception.dart';
import 'package:zockblock_app/core/error/retry_policy.dart';

void main() {
  group('gibt auf, wenn Wiederholen nichts bringt', () {
    const hopeless = <String, AppException>{
      'Unauthorized': UnauthorizedException(),
      'NotFound': NotFoundException(),
    };

    for (final entry in hopeless.entries) {
      test('${entry.key} wird nicht wiederholt', () {
        expect(appRetryPolicy(0, entry.value), isNull);
      });
    }
  });

  group('wiederholt, was sich von selbst erledigen kann', () {
    const retryable = <String, AppException>{
      'Network': NetworkException(),
      'Server': ServerException(),
      'Unknown': UnknownException(),
    };

    for (final entry in retryable.entries) {
      test('${entry.key} wird wiederholt', () {
        expect(appRetryPolicy(0, entry.value), isNotNull);
      });
    }
  });

  test('verdoppelt die Wartezeit pro Versuch', () {
    const error = NetworkException();

    expect(appRetryPolicy(0, error), const Duration(milliseconds: 300));
    expect(appRetryPolicy(1, error), const Duration(milliseconds: 600));
    expect(appRetryPolicy(2, error), const Duration(milliseconds: 1200));
    expect(appRetryPolicy(3, error), const Duration(milliseconds: 2400));
  });

  test('gibt nach dem vierten Versuch auf', () {
    const error = NetworkException();

    expect(appRetryPolicy(3, error), isNotNull);
    expect(appRetryPolicy(4, error), isNull);
    expect(appRetryPolicy(99, error), isNull);
  });

  test('wiederholt auch Fehler, die keine AppException sind', () {
    // Alles, was nicht durch den dio-Mapper lief - etwa ein Auth0-Fehler.
    // Im Zweifel lieber wiederholen als sofort aufgeben.
    expect(appRetryPolicy(0, Exception('irgendwas')), isNotNull);
  });
}
