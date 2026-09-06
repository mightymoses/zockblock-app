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

  /// Auth0-Tenant, gegen den angemeldet wird.
  ///
  /// Steht zusätzlich als `manifestPlaceholders` in
  /// `android/app/build.gradle.kts` – Gradle kann diese Konstante nicht lesen,
  /// beide Stellen müssen also zusammen geändert werden.
  static const String auth0Domain = String.fromEnvironment(
    'AUTH0_DOMAIN',
    defaultValue: 'zockblock.eu.auth0.com',
  );

  /// Client-ID der nativen Auth0-Anwendung.
  ///
  /// Kein Geheimnis: native Apps sind Public Clients und melden sich per PKCE
  /// an. Die ID steckt ohnehin im App-Binary und in der Login-URL im Browser.
  static const String auth0ClientId = String.fromEnvironment(
    'AUTH0_CLIENT_ID',
    defaultValue: 'saaES4mot3pMpTKt2ZHB9c1rDQrvPziy',
  );

  /// API-Identifier, den das Backend als Audience im Token erwartet.
  ///
  /// Ein Bezeichner, keine aufrufbare URL – muss auf beiden Seiten exakt
  /// gleich lauten.
  static const String auth0Audience = String.fromEnvironment(
    'AUTH0_AUDIENCE',
    defaultValue: 'https://zockblock.net',
  );
}
