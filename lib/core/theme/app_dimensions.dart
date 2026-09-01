import 'package:flutter/material.dart';

/// Abstufungen für Abstände und Padding.
class AppSpacing {
  AppSpacing._();

  /// Kleinster Abstand, z.B. zwischen Icon und Label
  static const double xs = 4;

  /// Kleiner Abstand, z.B. zwischen Listenelementen oder inneres Padding
  /// kleiner Komponenten
  static const double sm = 8;

  /// Mittlerer kleiner Abstand, z.B. Abstände innerhalb von Karten
  static const double md = 12;

  /// Standard-Abstand, z.B. Padding von Karten, Abstände zwischen Sektionen
  static const double lg = 16;

  /// Großer Abstand, z.B. Abstände zwischen größeren Sektionen
  static const double xl = 24;

  /// Sehr großer Abstand, z.B. Abstände zwischen Hauptbereichen einer Seite
  static const double xxl = 32;

  /// Großzügiger Abstand, z.B. oberer/unterer Seitenrand
  static const double xxxl = 48;

  /// Maximaler Abstand, z.B. Hero-Bereiche, große vertikale Abstände
  static const double huge = 64;
}

/// Abstufungen für Eckenrundungen.
class AppRadius {
  AppRadius._();

  /// Sehr kleine Rundung, z.B. kleine Tags oder Badges
  static const double xs = 4;

  /// Kleine Rundung, z.B. kleine Karten oder Eingabefelder
  static const double sm = 8;

  /// Mittlere Rundung, z.B. Buttons
  static const double md = 12;

  /// Standard-Rundung, z.B. Karten und Dialoge
  static const double lg = 16;

  /// Große Rundung, z.B. Bottom Sheets und große Karten
  static const double xl = 28;

  /// Vollständig rund, z.B. Chips, runde Buttons, Avatare
  static const double full = 999;

  /// [xs] als fertiges [BorderRadius]-Objekt.
  static const BorderRadius xsBorderRadius = BorderRadius.all(
    Radius.circular(xs),
  );

  /// [sm] als fertiges [BorderRadius]-Objekt.
  static const BorderRadius smBorderRadius = BorderRadius.all(
    Radius.circular(sm),
  );

  /// [md] als fertiges [BorderRadius]-Objekt.
  static const BorderRadius mdBorderRadius = BorderRadius.all(
    Radius.circular(md),
  );

  /// [lg] als fertiges [BorderRadius]-Objekt.
  static const BorderRadius lgBorderRadius = BorderRadius.all(
    Radius.circular(lg),
  );

  /// [xl] als fertiges [BorderRadius]-Objekt.
  static const BorderRadius xlBorderRadius = BorderRadius.all(
    Radius.circular(xl),
  );

  /// [full] als fertiges [BorderRadius]-Objekt.
  static const BorderRadius fullBorderRadius = BorderRadius.all(
    Radius.circular(full),
  );
}

/// Elevation-Stufen (Material 3)
///
/// Elevation kommuniziert wie weit ein Element vom Hintergrund "abgehoben" ist.
///
/// Faustregel: je wichtiger/vordergründiger ein Element, desto höher die
/// Elevation. Weniger ist mehr — die meisten Apps kommen mit 0, 1 und 2 aus.
class AppElevation {
  AppElevation._();

  /// Hintergrund, flache Karten (kein Schatten).
  static const double flat = 0;

  /// Karten, die leicht hervorgehoben sind.
  static const double low = 1;

  /// Karten mit Interaktion, z.B. tippbar.
  static const double medium = 2;

  /// Floating Action Button.
  static const double fab = 3;

  /// Navigationsleisten.
  static const double navigation = 4;

  /// Dialoge, Bottom Sheets, Modals.
  static const double modal = 5;
}
