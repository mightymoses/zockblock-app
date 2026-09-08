import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zockblock_app/core/user/animal_asset.dart';

part 'avatar.freezed.dart';

/// Welche der beiden Darstellungen ein Profil verwendet.
///
/// Bewusst ein eigener, gespeicherter Wert und nicht daraus abgeleitet, ob ein
/// Foto existiert: Nur so bleiben Tier und Foto beide erhalten, wenn der Nutzer
/// zwischen den Darstellungen hin- und herschaltet.
enum AvatarMode {
  /// Tierbild vor der gewaehlten Farbe.
  animal,

  /// Hochgeladenes Foto.
  photo,
}

/// Was fuer ein Profil tatsaechlich angezeigt wird.
///
/// Die Entscheidung zwischen Tier und Foto faellt einmal in [Avatar.of] und
/// nicht verteilt in den Widgets. Nach aussen bleiben nur die beiden Faelle
/// uebrig, die es zu zeichnen gibt - ein Widget kann sie erschoepfend
/// abhandeln, ohne selbst auf `null` pruefen zu muessen.
@freezed
sealed class Avatar with _$Avatar {
  const Avatar._();

  /// Tierbild vor der Hintergrundfarbe [color] (ARGB).
  ///
  /// [asset] ist `null`, solange kein Tier gewaehlt wurde oder das Backend
  /// eines liefert, das diese App-Version nicht kennt; [color] ist `null`,
  /// solange keine Farbe gewaehlt wurde. Beides zeichnet die Anzeige als
  /// schlichte Flaeche, dort liegt auch der Rueckfall auf die Theme-Farbe.
  const factory Avatar.animal({AnimalAsset? asset, int? color}) = AnimalAvatar;

  /// Hochgeladenes Foto, erreichbar unter [url].
  const factory Avatar.photo({required String url}) = PhotoAvatar;

  /// Waehlt die Darstellung aus den gespeicherten Profilwerten.
  ///
  /// Faellt auf das Tier zurueck, wenn [mode] zwar `photo` ist, aber keine
  /// [photoUrl] vorliegt. Das Backend verhindert diesen Zustand zwar beim
  /// Speichern, aber ein leerer Kreis waere die schlechtere Antwort darauf,
  /// falls er doch einmal auftritt.
  factory Avatar.of({
    required AvatarMode mode,
    String? animalName,
    int? color,
    String? photoUrl,
  }) {
    if (mode == AvatarMode.photo && photoUrl != null) {
      return Avatar.photo(url: photoUrl);
    }
    return Avatar.animal(asset: AnimalAsset.fromName(animalName), color: color);
  }
}
