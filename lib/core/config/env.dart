/// Zur Kompilierzeit gesetzte Umgebungskonfiguration der App.
///
/// Werte werden per `--dart-define` gesetzt und beim Build fest einkompiliert.
/// Ohne Override wird gegen das produktive Backend auf Render gebaut.
///
/// Lokal gegen ein eigenes Backend testen (z. B. im lokalen Netzwerk vom
/// Smartphone aus erreichbar):
/// ```sh
/// fvm flutter run --dart-define=API_BASE_URL=http://<lokale-ip>:8000/api
/// ```
/// Empfehlung: als gespeicherte Run-Konfiguration in der IDE hinterlegen,
/// statt das Flag jedes Mal manuell zu tippen.
class AppEnv {
  AppEnv._();

  /// Basis-URL der Backend-API, inklusive `/api`-Präfix.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://zockblock-backend.onrender.com/api',
  );
}
