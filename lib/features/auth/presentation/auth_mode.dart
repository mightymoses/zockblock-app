/// Zufällig gewählte Variante der Hintergrundanimation auf der Anmeldeseite.
enum AuthMode {
  /// Alle Reihen laufen durch.
  running,

  /// Die großen Reihen stehen, stattdessen drehen sich die Kreise.
  spinning,

  /// Die großen Reihen stehen still.
  pausing,
}
