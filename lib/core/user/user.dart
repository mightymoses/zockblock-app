import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zockblock_app/core/user/avatar.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Nutzerprofil, wie es das Backend liefert und entgegennimmt.
///
/// Die Feldnamen entsprechen denen der API (camelCase), deshalb kommt die
/// Serialisierung ohne Umbenennungen aus. `createdAt` und `updatedAt` liefert
/// das Backend zwar mit, sie fehlen hier aber bewusst: Die App braucht sie
/// nirgends, und unbekannte JSON-Schluessel werden beim Parsen ignoriert.
@freezed
abstract class User with _$User {
  /// Erstellt ein Nutzerprofil; [id] vergibt das Backend.
  ///
  /// Ausser [username] ist alles optional - das Backend laesst die Felder
  /// leer, solange der Nutzer sie nicht gesetzt hat. [avatarColor] ist ein
  /// ARGB-Wert (`0xFF52A788`), keine Position in einer Palette: So ueberlebt
  /// eine gespeicherte Farbe jede Aenderung an der Farbauswahl.
  const factory User({
    required String username,
    String? id,
    String? animalAssetName,
    int? avatarColor,
    String? bioLine1,
    String? bioLine2,
    String? avatarUrl,
    // unknownEnumValue faengt einen Modus ab, den erst eine neuere
    // Backend-Version kennt - lieber das Tier zeigen als beim Parsen werfen.
    @JsonKey(unknownEnumValue: AvatarMode.animal)
    @Default(AvatarMode.animal)
    AvatarMode avatarMode,
  }) = _User;

  /// Erlaubt die Getter weiter unten; freezed verlangt dafuer einen privaten
  /// Konstruktor.
  const User._();

  /// Erstellt ein Nutzerprofil aus der JSON-Antwort des Backends.
  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);

  /// Was fuer dieses Profil angezeigt wird - Foto oder Tier vor Farbe.
  ///
  /// Die Entscheidung faellt in [Avatar.of] und nicht in den Widgets, damit
  /// ueberall dasselbe herauskommt.
  Avatar get avatar => Avatar.of(
    mode: avatarMode,
    animalName: animalAssetName,
    color: avatarColor,
    photoUrl: avatarUrl,
  );
}
