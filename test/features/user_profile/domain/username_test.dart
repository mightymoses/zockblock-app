import 'package:flutter_test/flutter_test.dart';
import 'package:zockblock_app/features/user_profile/domain/username.dart';

void main() {
  group('leer', () {
    const blank = <String, String>{
      'leerer String': '',
      'nur Leerzeichen': '   ',
      'nur Tabs und Zeilenumbruch': '\t\n',
    };

    for (final entry in blank.entries) {
      test('${entry.key} ist empty, nicht tooShort', () {
        expect(
          Username.validate(entry.value),
          UsernameValidationError.empty,
        );
      });
    }
  });

  test('kürzer als minLength ist tooShort', () {
    expect(Username.validate('ab'), UsernameValidationError.tooShort);
  });

  test('genau minLength ist gültig', () {
    expect(Username.validate('abc'), isNull);
  });

  test('länger als minLength ist gültig', () {
    expect(Username.validate('mightymoses'), isNull);
  });

  test('gezählt wird nach dem Trimmen', () {
    // Fünf Zeichen roh, drei nach dem Trimmen - muss gültig sein.
    expect(Username.validate(' abc '), isNull);
    // Vier Zeichen roh, zwei nach dem Trimmen - muss zu kurz sein.
    expect(Username.validate(' ab '), UsernameValidationError.tooShort);
  });
}
