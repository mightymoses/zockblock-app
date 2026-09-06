/// Grund, warum ein Nutzername ungültig ist.
enum UsernameValidationError {
  /// Nutzername ist leer (nach Trimmen).
  empty,

  /// Nutzername ist kürzer als [Username.minLength] Zeichen.
  tooShort,
}

/// Validierungsregeln für Nutzernamen.
class Username {
  Username._();

  /// Mindestlänge eines gültigen Nutzernamens.
  static const minLength = 3;

  /// Prüft [value] gegen die Regeln, gibt den Fehlergrund zurück oder
  /// `null`, wenn [value] ein gültiger Nutzername ist.
  static UsernameValidationError? validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return UsernameValidationError.empty;
    }
    if (trimmed.length < minLength) {
      return UsernameValidationError.tooShort;
    }
    return null;
  }
}
