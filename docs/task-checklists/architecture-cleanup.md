# Architektur- & Code-Quality-Cleanup

Branch: `refactor/architecture-cleanup` (von `feature/create-user-profile`)

Ziel: Aktuellen Stand an die in `CLAUDE.local.md` dokumentierte Zielarchitektur
angleichen, Auth-Token-Handling korrigieren, Backend-URL auf Render umstellen,
sowie diverse beim Review gefundene Smells beseitigen.

Reihenfolge unten = empfohlene Abarbeitungsreihenfolge (kleine/risikoarme
Punkte zuerst, danach die größeren strukturellen Umbauten). Vor jedem Punkt
nochmal kurzer Planungsdurchlauf, siehe Workflow in `CLAUDE.local.md`.

---

## A) Backend-URL konfigurierbar machen

Render-URL: `https://zockblock-backend.onrender.com`

- [x] Neu: `lib/core/config/env.dart` – `AppEnv.apiBaseUrl` via
      `String.fromEnvironment('API_BASE_URL', defaultValue:
      'https://zockblock-backend.onrender.com/api')`
- [x] `lib/core/dio/dio_provider.dart`: nutzt `AppEnv.apiBaseUrl` statt
      hardcodierter IP
- [x] Hinweis zum lokalen Override (`--dart-define=API_BASE_URL=...`,
      empfohlen als gespeicherte IDE-Run-Konfiguration) als Doc-Comment direkt
      in `env.dart` – kompakter als README/CLAUDE.local.md anzufassen
- [x] Aktuell modifizierte Zeile in `dio_provider.dart` (lokale IP) damit
      hinfällig

**Bewusst NICHT umgesetzt:** `shared_preferences`-Laufzeit-Override für die
Backend-URL – IDE-Run-Konfigurationen lösen das Umschalt-Bedürfnis ohne
Zusatzcode.

---

## D) `routing/` auf Top-Level verschieben ✅

- [x] `lib/core/routing/app_router.dart` → `lib/routing/app_router.dart`
- [x] Import in `lib/main.dart` anpassen
- [x] Sonstige Importe von `core/routing/...` angepasst (`home_screen.dart`,
      `user_profile_screen.dart` – fallen aber ohnehin unter Punkt E weg)
- [x] `flutter analyze` – keine Findings

---

## J) Netzwerk-Ordner vereinheitlichen ✅

Entscheidung: generischer Name (`network`) statt library-spezifisch (`dio`) –
zukunftssicherer, falls der HTTP-Client mal getauscht wird.

- [x] `lib/core/dio/dio_provider.dart` → `lib/core/network/dio_provider.dart`
      (Inhalt unverändert), `core/dio/` entfernt
- [x] Import in `user_service.dart` angepasst
- [x] `flutter analyze` – keine Findings

---

## K) Tooling/Doku-Abgleich ✅

- [x] `import_lint` eingerichtet: Regeln für core/shared/features-Richtung,
      pages/routing folgen mit Punkt E
- [x] `fvm` eingerichtet, Flutter 3.44.2 gepinnt (`.fvmrc`)
- [x] Lint-Preset auf `very_good_analysis` umgestellt (inkl.
      `public_member_api_docs`); bestehende Findings via `dart fix --apply`
      + `dart format` großteils behoben (307 → 168), Rest (v. a. fehlende
      Doc-Comments) wird graduell beim Anfassen der jeweiligen Datei in
      B/C/E nachgezogen, kein separater Cleanup-Task
- [x] `CLAUDE.local.md` entsprechend aktualisiert (Lint-Zeile, Doc-Comment-Stil)
- [x] `test/widget_test.dart` (veralteter Default-Test) entfernt

---

## B) Auth-Session-Architektur bereinigen ✅

- [x] Verschieben `features/auth/data/*` → `lib/core/auth/`, Importe anpassen,
      leeren `features/auth/data/`-Ordner löschen
- [x] Toter Code raus: `features/auth/presentation/auth_viewmodel.dart`
- [x] `AuthSessionNotifier`: `renewSession()` entfernen (wird nicht mehr gebraucht)
- [x] Neu `core/network/auth_interceptor.dart`: `AuthInterceptor extends
      QueuedInterceptor`, `AuthService` per Konstruktor injiziert, holt Token
      direkt über `getCredentials()` (Auth0 refresht selbst), `on
      CredentialsManagerException` → Request ohne Header raus. Mutiert
      `authSessionProvider` nicht mehr
- [x] `dio_provider.dart` verdrahtet nur noch `AuthInterceptor`
- [x] `AuthRepositoryImpl.getExistingSession()`: nur bei
      `isNoCredentialsFound`/`isNoRefreshTokenFound` → `null`, sonst `rethrow`
      (dabei auch `AuthService.hasValidCredentials()` entfernt, unbenutzt)
- [x] `UserRepositoryImpl.getCurrentUser()`: nur `DioException` mit Status 404
      → `null`, sonst `rethrow`
- [x] `UserService.getCurrentUser()`/`createUser()`: `_dio.get`/`.post` ohne
      Typ-Parameter behoben (`dynamic`→`Map<String, Object?>`-Cast-Fund von
      strict-casts), `<Map<String, Object?>>` explizit angeben
- [x] `UserRepositoryImpl.createUser()`: kein Catch-and-swallow mehr,
      Rückgabetyp `Future<User>` (kein Null-Fall mehr); Interface angepasst;
      `ProfileSetupViewModel.submitForm()`/`ProfileSetup` um `submitError`
      erweitert (aktuell `return true` unconditional, obwohl `createUser()`
      fehlschlagen kann), Screen zeigt den Fehler an
- [x] Router-Refresh-Fix: `onAuthStateChangedProvider`/
      `onUserStateChangedProvider` + beide `StreamController<bool>` +
      `onXStateChanged`-Interface-Member komplett entfernt, stattdessen
      `_RouterRefreshListenable` (ChangeNotifier) in `app_router.dart` als
      `refreshListenable`, lauscht auf `authSessionProvider`+`userProvider`;
      manuelle `ref.listen(...).router.refresh()` in `main.dart` entfernt
- [x] Router-Redirect: `userAsyncValue`-Zweig bei `error` nicht mehr erzwungen
      zu `/profile-setup` navigieren, sondern wie `loading` behandeln
      (`=> null`); `authSessionAsyncValue`-Zweig bleibt bei `error` → `/auth`
      (sicherer Fallback, unverändert)
- [x] Nebenbei: `auth_screen.dart` Kleinfunde behoben (`Future<void>.delayed`,
      `unawaited(_startLoop())`, `.isEven` statt `% 2 == 0`)

---

## C) `domain/`-Layer nachziehen ✅

- [x] Neu `features/user_profile/domain/username.dart`: `Username`
      (Value-Object) + `UsernameValidationError`-Enum. Domain liefert nur das
      Ergebnis, keine Texte – `ProfileSetupViewModel._usernameErrorMessage()`
      mappt Enum → String (TODO: auf `AppLocalizations` bei Punkt E)
- [x] `features/auth/domain/`: keine fachlichen Regeln gefunden (Login/Logout
      delegieren nur an Auth0) – bewusst nicht angelegt

---

## F) SVG → WebP für animierte Grafiken ✅ (Performance bestätigt)

- [x] `zock.svg`/`block.svg` als `assets/images/zock.webp`/`block.webp`
      exportiert (1200×600); `MarqueeRow`: `SvgPicture.asset(...,
      colorFilter: ...)` → `Image.asset(..., color: color, colorBlendMode:
      BlendMode.srcIn)`
- [x] Die 8 `{Zock,Block}-{Links,Rechts}_{Bright,Dark}.svg` als
      `assets/images/{zock,block}_{links,rechts}_{bright,dark}.webp`
      exportiert (1024×1024, lowercase_with_underscores statt der
      inkonsistenten SVG-Namen); `SpinningCircle`: `SvgPicture.asset` →
      `Image.asset`
- [x] Alte SVGs entfernt, `Pfeil-Links.svg`/`Pfeil-Rechts.svg` unverändert
      (einmalig, nicht animiert) – `flutter_svg`-Dependency bleibt dafür
- [x] Performance-Check auf echtem Gerät durchgeführt, spürbar flüssiger

---

## E) `pages/`-Schicht einführen ✅

Alle vier `*_screen.dart` in Page (Chrome) + Section (Inhalt) zerlegt, alte
Screen-Dateien gelöscht.

- [x] `pages/{auth,home,profile_setup,user_profile}_page.dart` angelegt
- [x] Sections: `features/auth/presentation/auth_section.dart`,
      `features/home/presentation/home_section.dart`,
      `features/user_profile/presentation/{profile_setup,user_profile}_section.dart`
- [x] Neu `shared/widgets/organisms/app_page_scaffold.dart`: AppBar +
      Hintergrundgrafik + Padding, war 3× dupliziert
- [x] Neu `shared/widgets/atoms/app_filled_button.dart`: der 4× duplizierte
      Button-Style. Farben bleiben bewusst hart verdrahtet (weiß/schwarz),
      solange nicht entschieden ist, ob die App bei Dynamic Colors bleibt –
      diese Datei ist dann die einzige Änderungsstelle
- [x] `ref.watch(routerProvider).go(...)` → `context.go(...)`
- [x] Alle hardcodierten Strings nach `l10n/app_{de,en}.arb` (inkl. Tippfehler
      "Nuzterprofil"); `ProfileSetup` hält jetzt `UsernameValidationError?` +
      `hasSubmitError` statt fertiger Texte, die Übersetzung passiert in der
      Section (Notifier haben keinen `BuildContext`) – löst das TODO aus C
- [x] `app_router.dart`: Route-Ziele kommen aus `pages/`
- [x] import_lint-Regeln für `pages` und `routing` aktiviert
- [x] Doc-Comments in den zuletzt noch offenen Dateien nachgezogen
      (`auth_mode`, `marquee_row`, `spinning_circle`, `user`, `user_provider`,
      `main`, `app_colors`, `app_dimensions`, `env`); `app_theme.dart` ist
      generiert und per `ignore_for_file` ausgenommen
- [x] `pubspec.yaml`: Dependencies sortiert, ungenutztes `flutter_lints`
      entfernt (Preset ist `very_good_analysis`)

**Offener Punkt (bewusst nicht hier entschieden):** `app_router.dart` und
`home_section.dart` greifen für das Profil-Gate bzw. die Begrüßung auf
`features/user_profile/data/user_provider.dart` zu – ein routing→features- und
ein features→fremdes-feature/data-Verstoß. Naheliegende Lösung analog zu
`core/auth/`: den Zustand des aktuellen Nutzers nach `core/user/` ziehen. Bis
dahin steht in `analysis_options.yaml` eine benannte, kommentierte Ausnahme.

---

## G) Aktuellen Nutzer nach `core/user/` ziehen ✅

Entscheidung: der komplette Datenzugriff wandert, inkl. `createUser` –
spiegelbildlich zu `core/auth/`. Die offizielle Flutter-Architektur-Empfehlung
legt Repositories/Services ohnehin generell außerhalb der Feature-Ordner ab
("aren't tied to a single feature"), wir tun es nur für diesen Fall.

- [x] `features/user_profile/data/*` → `core/user/` (`user.dart` + generierte
      Dateien, `user_service`, `user_repository`, `user_repository_impl`);
      `features/user_profile/` hat jetzt nur noch `domain/` + `presentation/`
- [x] `user_provider.dart` → `core/user/current_user_provider.dart`,
      `userProvider` → `currentUserProvider`, `UserNotifier` →
      `CurrentUserNotifier` – der Name sagt jetzt "der angemeldete", nicht
      "irgendein" Nutzer
- [x] Importe in `app_router.dart`, `home_section.dart`,
      `user_profile_section.dart`, `profile_setup_viewmodel.dart` angepasst
- [x] Ausnahme in `analysis_options.yaml` entfernt
- [x] `flutter analyze` + `import_lint` – keine Findings

**Bewusst NICHT umgesetzt:** feingranulare import_lint-Regeln, die einem
Feature nur das `domain/` eines anderen erlauben. Mit Globs nicht ausdrückbar
(bräuchte eine Regel pro Feature), und eine beim nächsten Feature vergessene
Regel meldet nichts, sondern erlaubt still alles. Falls es relevant wird:
Barrel-Dateien pro Feature via `barrel_file_lints` – das Dart-Pendant zu Nx'
`index.ts`, skaliert ohne Enumeration.

---

## H1) Fehlerbehandlung ✅

Heute enden zwei von drei Fehlerpfaden im stillen leeren Bildschirm:
`currentUserProvider` im Fehlerfall → `maybeWhen(orElse: SizedBox.shrink)` in
`home_section`/`user_profile_section`. Bei Render-Kaltstarts (Free-Tier fährt
nach Leerlauf herunter) ist das kein Randfall, sondern der Normalfall beim
ersten Start.

Entscheidungen vorab: **kein** Result-Pattern (`AsyncValue` ist bereits einer,
beides wäre doppelte Verpackung), **keine** Riverpod-Mutations (laut Doku
"may change in a breaking way without a major version bump").

- [x] `core/error/app_exception.dart`: `sealed class AppException` mit
      `NetworkException`, `ServerException`, `UnauthorizedException`,
      `NotFoundException`, `UnknownException` – bewusst klein halten
- [x] `core/error/dio_error_mapper.dart`: `DioException` → `AppException`.
      Mapping im **Service**, nicht im Interceptor (dio packt in `onError`
      alles wieder in eine `DioException`, der Typ wäre nicht ersetzbar)
- [x] `user_service.dart` mappt; `user_repository_impl.dart` fängt
      `NotFoundException` statt `DioException`+404 → dio ist danach oberhalb
      des Service unbekannt
- [x] `dio_provider.dart`: Timeouts hoch (10s reicht für einen Kaltstart
      nicht) – `connect` 15s, `receive` 60s, `send` 30s
- [x] Globale `retry`-Policy (`core/error/retry_policy.dart`, im `ProviderScope`) im `ProviderScope`: Riverpod 3 retryt per Default
      **jeden** Fehler unbegrenzt. Bei `UnauthorizedException`/
      `NotFoundException` abbrechen (heilt nicht von selbst), sonst nach
      wenigen Versuchen aufgeben
- [x] `shared/widgets/molecules/error_view.dart`: Fehlertext + Retry-Button,
      plus `appErrorMessage()` (AppException → lokalisierter Text)
- [x] `shared/widgets/molecules/async_value_view.dart`: einheitliches
      data/loading/error-Rendering, ersetzt `maybeWhen(orElse: shrink)`
- [x] `home_section` + `user_profile_section` auf `AsyncValueView` umstellen
- [x] SnackBar via `ref.listen` für Login (`auth_section`) und Logout
      (`user_profile_section`) – dort fehlt nichts auf dem Schirm, deshalb
      transient statt inline
- [x] Neue ARB-Keys (de/en) für die Fehlertexte + "Erneut versuchen"
- [x] `flutter analyze` + `import_lint` – keine Findings

**Weiter offen:** Der Router-Redirect schickt bei `authSession`-Fehler auf
`/auth`. Bei reinem Netzwerkfehler loggt das einen eingeloggten Nutzer beim
Offline-Start optisch aus. Bewusst nicht mitverändert, weil es Routing-
Verhalten ist und nicht Fehleranzeige – zu entscheiden, ob `NetworkException`
dort wie `loading` behandelt werden soll.

---

## H2a) Logging

`logger` schreibt nur lokal in die Konsole, es verlaesst das Geraet nicht.
Level im Release auf `warning`, im Debug auf `debug`.

- [ ] `core/logging/logger_provider.dart`: `createAppLogger()` + `loggerProvider`
- [ ] `core/logging/app_provider_observer.dart`: `ProviderObserver` mit
      `providerDidFail(ProviderObserverContext, Object, StackTrace)`, darin
      `if (error is ProviderException) return;` gegen Doppelmeldungen
- [ ] `main.dart`: Logger einmal bauen, an Observer *und* per
      `overrides: [loggerProvider.overrideWithValue(logger)]` an den Container
      geben - der Observer existiert vor dem Container
- [ ] `auth_interceptor.dart`: die verschluckte `CredentialsManagerException`
      loggen (Request geht sonst kommentarlos ohne Token raus)

Bewusst nicht: `didUpdateProvider` loggen (Rauschen), und keine
`ErrorReporter`-Abstraktion (der Observer wird genau einmal registriert, in
Tests laesst man ihn weg).

---

## H2b) Crash-Reporting + Einwilligung

Entscheidung: **Crashlytics statt Sentry**. Firebase kommt fuer FCM ohnehin,
der einzige echte Vorteil von Sentry waere der wegfallende US-Transfer - die
Einwilligungsfrage nach TDDDG ist bei beiden identisch. Kein
`firebase_analytics` (Verhaltens-Tracking, zieht Consent-Pflicht nach sich,
fuer Crashlytics nicht noetig).

**Vorbedingung, vor allem anderen:** `applicationId` und iOS-Bundle-ID stehen
noch auf `com.example.*`. Die wandern in `google-services.json` und sind danach
faktisch fest - und `com.example.*` laesst sich nicht im Play Store
veroeffentlichen. Also erst umbenennen, dann Firebase.

- [ ] `applicationId`/`namespace` (Android) und `PRODUCT_BUNDLE_IDENTIFIER`
      (iOS) auf eine echte ID aendern
- [ ] Firebase-Projekt anlegen (dasselbe, das spaeter das Backend fuer FCM
      nutzt), `flutterfire configure`
- [ ] `firebase_core` + `firebase_crashlytics`; `firebase_options.dart`,
      `google-services.json`, `GoogleService-Info.plist` einchecken (laut
      Firebase keine Secrets)
- [ ] Sammlung standardmaessig aus:
      `firebase_crashlytics_collection_enabled=false` im Android-Manifest
- [ ] `core/consent/`: Zustand `nichtGefragt`/`zugestimmt`/`abgelehnt` in
      `shared_preferences` (erste Verwendung des Pakets)
- [ ] Einwilligungs-Dialog beim **ersten App-Start** (nicht nach dem
      Profil-Setup, sonst fehlen Onboarding-Abstuerze): zwei gleichwertige
      Buttons, nichts vorausgewaehlt, Link zur Datenschutzerklaerung.
      Zustimmung zur Datenschutzerklaerung ist *keine* Einwilligung - die
      muss spezifisch fuer diesen Zweck erfolgen
- [ ] `main.dart`: `Firebase.initializeApp`, `FlutterError.onError` +
      `PlatformDispatcher.instance.onError`, `setCrashlyticsCollectionEnabled`
      abhaengig vom Einwilligungszustand
- [ ] Der `ProviderObserver` aus H2a meldet zusaetzlich an Crashlytics
      (`recordError(..., fatal: false)`)

Nicht-Code, aber Teil des Themas: Datenschutzerklaerung, Play-Data-Safety-
Formular, Apple Privacy Nutrition Labels.

---

## H2c) Einstellungen (Widerruf)

Faellt aus H2b heraus, weil es neue UI ist: der Widerruf der Einwilligung ist
verpflichtend, es gibt aber noch keinen Einstellungs-Screen.

- [ ] `pages/settings_page.dart` + `features/settings/presentation/
      settings_section.dart` mit Schalter "Fehlerberichte senden"
- [ ] Route + Einstieg vom Nutzerprofil aus


## M) Auth0-Konfiguration vereinheitlichen

Befund der Bestandsaufnahme: **kein Sicherheitsproblem.** In
`auth_service.dart` stehen Auth0-Domain, Client-ID und Audience hartcodiert,
in `build.gradle.kts` nochmal die Domain. Ein Client *Secret* existiert
nirgends - richtig so, native Apps sind Public Clients und nutzen PKCE. Die
Client-ID ist kein Geheimnis: sie steckt zwangslaeufig im App-Binary und in
der Login-URL im Browser, Auth0 behandelt sie wie eine oeffentliche Kennung.
Gleiche Kategorie wie `firebase_options.dart`.

Was trotzdem stoert, ist Konfigurierbarkeit und Doppelung - genau das, was
Punkt A fuer die Backend-URL schon geloest hat:

- [ ] Auth0-Domain, Client-ID und Audience nach `core/config/env.dart`
      (`AppEnv`), per `String.fromEnvironment` mit Default - analog zu
      `apiBaseUrl`. Erlaubt einen zweiten Auth0-Tenant fuer Dev/Prod, ohne
      Code zu aendern
- [ ] Die Domain steht doppelt (Dart + Gradle-`manifestPlaceholders`). Gradle
      kommt nicht an `AppEnv`; entweder `gradle.properties` als einzige Quelle
      oder die Doppelung bewusst dokumentieren
- [ ] Im Auth0-Dashboard pruefen, dass der Application Type **Native** ist
      (Public Client + PKCE) und nicht "Regular Web Application" - bei
    letzterem waere ein Client Secret im Spiel, das nicht in eine App gehoert
- [ ] `audience: 'https://zockblock.net'` gegenpruefen: das ist der
      API-Identifier aus dem Auth0-Dashboard, keine aufloesbare URL. Muss mit
      dem uebereinstimmen, was das Backend als Audience erwartet

---


## I) Tests aufsetzen

- [ ] `mocktail` als dev_dependency ergänzen (steht im Stack, fehlt noch)
- [ ] Zu klären vorab: Welche Ebenen decken wir ab und wie tief? Vorschlag als
      Startpunkt – Unit für `domain/` (`Username`) und `data/`
      (Repository-Impls mit gemocktem Service), ViewModel-Tests für
      `ProfileSetupViewModel` (Riverpod `ProviderContainer`), Widget-Tests für
      die Sections
- [ ] Zu klären vorab: Golden Tests jetzt schon (Auth-Animation ist dafür
      heikel) oder erst wenn die UI steht?
- [ ] Test-Ordnerstruktur spiegelt `lib/` (Konvention festhalten)
- [ ] `integration_test` erst, wenn es einen durchgehenden Flow gibt

---

## L) CI (GitHub Actions)

Zuletzt, damit die Pipeline gleich den vollständigen Satz inkl. Tests prüft.

- [ ] Workflow `.github/workflows/ci.yml`: `fvm`-Version aus `.fvmrc`,
      `flutter pub get`, `dart format --set-exit-if-changed`,
      `flutter analyze`, `dart run import_lint`, `flutter test`
- [ ] Zu klären vorab: Trigger (nur PRs auf `main` oder jeder Push?),
      Caching, und ob Coverage hochgeladen werden soll
- [ ] Zu klären vorab: Build-Jobs für Android/iOS-Artefakte schon jetzt oder
      später – braucht Signing-Secrets und die Firebase-Configs aus H

---

## Abschluss

Nach E waren alle Checks grün; am Ende noch einmal vollständig durchlaufen:

- [ ] `fvm dart format .`
- [ ] `fvm flutter analyze`
- [ ] `fvm dart run import_lint`
- [ ] `fvm flutter test`
- [ ] `docs/architecture/feature-status.md` auf den Endstand bringen
