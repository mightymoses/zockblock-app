import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Nutzerprofil, wie es das Backend liefert und entgegennimmt.
@freezed
abstract class User with _$User {
  /// Erstellt ein Nutzerprofil; [id] vergibt das Backend.
  const factory User({required String username, String? id}) = _User;

  /// Erstellt ein Nutzerprofil aus der JSON-Antwort des Backends.
  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
