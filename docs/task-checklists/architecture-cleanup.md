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

## H2a) Logging ✅

`logger` schreibt nur lokal in die Konsole, es verlaesst das Geraet nicht.
Korrektur zum urspruenglichen Plan: ein Release-Level einzustellen waere
wirkungslos - der Default-Filter (`DevelopmentFilter`) unterdrueckt im Release
*alle* Ausgaben. Genau richtig so, fuer Produktion ist H2b zustaendig.

- [x] `core/logging/logger_provider.dart`: `createAppLogger()` + `loggerProvider`
      (`PrettyPrinter` mit `methodCount: 0` gegen Rauschen, Stacktraces nur
      bei Fehlern ueber `errorMethodCount`)
- [x] `core/logging/app_provider_observer.dart`: `ProviderObserver` mit
      `providerDidFail(ProviderObserverContext, Object, StackTrace)`, darin
      `if (error is ProviderException) return;` gegen Doppelmeldungen.
      Muss `final class` sein (Riverpod deklariert `abstract base class`),
      und `ProviderException` kommt aus `flutter_riverpod/misc.dart`
- [x] `main.dart`: Logger einmal bauen, an Observer *und* per
      `overrides: [loggerProvider.overrideWithValue(logger)]` an den Container
      geben - der Observer existiert vor dem Container
- [x] `auth_interceptor.dart`: die verschluckte `CredentialsManagerException`
      loggen - `isNoCredentialsFound`/`isNoRefreshTokenFound` nur auf `debug`
      (schlicht nicht eingeloggt, passiert bei jedem Start), alles andere als
      `warning` (Token-Erneuerung gescheitert - der spaetere Raetsel-401)

Bewusst nicht: `didUpdateProvider` loggen (Rauschen), und keine
`ErrorReporter`-Abstraktion (der Observer wird genau einmal registriert, in
Tests laesst man ihn weg).

- [x] `flutter analyze` + `import_lint` - keine Findings

---

## H2b) Crash-Reporting + Einwilligung ✅

Entscheidung: **Crashlytics statt Sentry**. Firebase kommt fuer FCM ohnehin,
der einzige echte Vorteil von Sentry waere der wegfallende US-Transfer - die
Einwilligungsfrage nach TDDDG ist bei beiden identisch. Kein
`firebase_analytics` (Verhaltens-Tracking, zieht Consent-Pflicht nach sich,
fuer Crashlytics nicht noetig).

**Vorbedingung, vor allem anderen:** `applicationId` und iOS-Bundle-ID stehen
noch auf `com.example.*`. Die wandern in `google-services.json` und sind danach
faktisch fest - und `com.example.*` laesst sich nicht im Play Store
veroeffentlichen. Also erst umbenennen, dann Firebase.

- [x] `applicationId`/`namespace` (Android) und `PRODUCT_BUNDLE_IDENTIFIER`
      (iOS) auf `com.zockblock.app` geaendert; Auth0-Callback-/Logout-URLs im
      Dashboard nachgezogen (die enthalten den Package-Namen)
- [x] Firebase-Projekt `zockblock-edb50` angelegt, `flutterfire configure`
      (Analytics ist im Projekt verknuepft, ohne `firebase_analytics`-Paket
      fliessen daraus aber keine Daten)
- [x] `firebase_core` + `firebase_crashlytics`; `firebase_options.dart`,
      `google-services.json`, `GoogleService-Info.plist` einchecken (laut
      Firebase keine Secrets)
- [x] Sammlung standardmaessig aus:
      `firebase_crashlytics_collection_enabled=false` im Android-Manifest
- [x] `core/consent/`: `CrashReportConsent`-Enum (`notAsked`/`granted`/
      `denied`) in `shared_preferences`; gespeichert wird der `name`, nicht der
      Index. Bewusst ohne Repository-Interface - ein einzelner Schluessel, und
      `setMockInitialValues()` deckt Tests ab
- [x] Einwilligungs-Dialog beim **ersten App-Start** (nicht nach dem
      Profil-Setup, sonst fehlen Onboarding-Abstuerze): zwei gleichwertige
      Buttons, nichts vorausgewaehlt, Link zur Datenschutzerklaerung.
      Zustimmung zur Datenschutzerklaerung ist *keine* Einwilligung - die
      muss spezifisch fuer diesen Zweck erfolgen
- [x] `main.dart`: `Firebase.initializeApp`, `FlutterError.onError` +
      `PlatformDispatcher.instance.onError`. Das Scharfschalten liegt in
      `core/crash_reporting/crash_reporting_provider.dart` - `WidgetRef.listen`
      kennt kein `fireImmediately`, der gespeicherte Startwert waere sonst nie
      angewendet worden
- [x] Der `ProviderObserver` aus H2a meldet zusaetzlich an Crashlytics,
      `fatal: false` (die App laeuft weiter) und mit `reason`, damit
      Crashlytics nach Provider gruppiert

- [x] Auf dem Geraet geprueft: Consent-Seite beim ersten Start, danach
      regulaerer Ablauf
- [x] `flutter analyze` + `import_lint` - keine Findings

**Noch offen (iOS):** Das Pendant zum Manifest-Eintrag
(`FirebaseCrashlyticsCollectionEnabled = false` in der `Info.plist`) und die
`GoogleService-Info.plist` fehlen - beides erzeugt `flutterfire configure`
erst auf einem Mac. Beim ersten iOS-Build nachholen, sonst sammelt iOS ohne
Einwilligung.

Nicht-Code, aber Teil des Themas: Datenschutzerklaerung, Play-Data-Safety-
Formular, Apple Privacy Nutrition Labels.

---

## H2c) Widerruf der Einwilligung ✅

Entscheidung: **kein eigener Einstellungs-Screen**, der Schalter kommt
vorerst aufs bestehende Nutzerprofil. Ein Screen mit genau einem Schalter
waere eine leere Huelle, und wie die Features spaeter geschnitten werden, ist
noch offen. Der Widerruf muss laut DSGVO genauso einfach sein wie das
Zustimmen - deshalb sofort sichtbar statt hinter einem weiteren Screen.

- [x] ARB: `consentToggleLabel` neu; `consentBody` sagt jetzt "in deinem
      Nutzerprofil" statt "in den Einstellungen" - der Satz muss beschreiben,
      was es wirklich gibt
- [x] `SwitchListTile` in `user_profile_section.dart`, liest und schreibt
      `crashReportConsentProvider`. `value` kommt direkt aus dem Enum, es gibt
      keinen zweiten Zustand im Widget - schlaegt das Speichern fehl, springt
      der Schalter zurueck statt eine Zustimmung vorzutaeuschen
- [x] Wirkt sofort: `crashReportingProvider` beobachtet die Einwilligung
      ohnehin, es braucht keinen zusaetzlichen Code und keinen Neustart
- [x] `flutter analyze` + `import_lint` - keine Findings

**Vorlaeufig, bewusst:** Die Consent-UI liegt jetzt an zwei Stellen - die
Frage in `features/consent/`, der Schalter in `features/user_profile/`.
Zusammenlegen geht nicht, weil ein Feature nicht auf `presentation/` eines
anderen zugreifen darf; beide haengen aber nur an `core/consent/`, also kein
Verstoss. Siehe auch den Zuschnitt-Punkt in
`docs/architecture/feature-status.md`.


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

- [x] Auth0-Domain, Client-ID und Audience nach `core/config/env.dart`
      (`AppEnv`), per `String.fromEnvironment` mit Default - analog zu
      `apiBaseUrl`. `auth_service.dart` liest nur noch `AppEnv`
- [x] Die Doppelung (Dart + Gradle-`manifestPlaceholders`) bleibt bestehen -
      es gibt keinen gemeinsamen Ort: `String.fromEnvironment` landet im
      Dart-Snapshot, `manifestPlaceholders` im AndroidManifest.
      `gradle.properties` haette nur die Gradle-Kopie verschoben. Stattdessen
      zeigen beide Stellen per Kommentar aufeinander
- [x] *(Dashboard, offen)* Pruefen, dass der Application Type **Native** ist
      (Public Client + PKCE) und nicht "Regular Web Application" - bei
    letzterem waere ein Client Secret im Spiel, das nicht in eine App gehoert
- [x] *(Dashboard, offen)* `audience: 'https://zockblock.net'` gegenpruefen: das ist der
      API-Identifier aus dem Auth0-Dashboard, keine aufloesbare URL. Muss mit
      dem uebereinstimmen, was das Backend als Audience erwartet

**iOS-Seite (kein akutes Problem, aber unvollstaendig).** Nachgeprueft: die
`Info.plist` ist die unveraenderte Flutter-Vorlage, es gibt keine
`.entitlements`-Datei. Laut auth0_flutter-README ist `useHTTPS: true` aber
kein Alles-oder-nichts - das SDK faellt auf iOS < 17.4 automatisch auf das
Custom-Scheme zurueck, und dessen Callback-URL ist im Dashboard hinterlegt.
Der Login ist auf iOS also nicht generell kaputt.

Erst auf **iOS 17.4+** greifen Universal Links, und dann fehlt:

- [ ] Associated-Domains-Capability `applinks:zockblock.eu.auth0.com` in Xcode
      (erzeugt die `Runner.entitlements`)
- [ ] Apple Team ID + Bundle-ID unter Advanced Settings > Device Settings im
      Auth0-Dashboard

Beides setzt einen **bezahlten** Apple-Developer-Account voraus, und die App
muss auch im Simulator mit dem Team-Zertifikat signiert sein. Alternative
waere `useHTTPS: false` (Custom-Scheme ueberall, kein Setup noetig) - dann
aber anfaellig fuer Client-Impersonation nach RFC 8252, weshalb Auth0
Universal Links empfiehlt. Entscheidung faellt beim ersten Mac-Build, dort
sowieso zusammen mit den offenen iOS-Punkten aus H2b
(`GoogleService-Info.plist`, `FirebaseCrashlyticsCollectionEnabled`).

---


## I) Tests aufsetzen ✅

Konventionen: `test/` spiegelt `lib/`. Unit-Tests ueber
`ProviderContainer.test()` - der raeumt sich per `addTearDown` selbst auf und
prueft am Testende, dass kein Container vergessen wurde. Dabei
`retry: (_, _) => null` mitgeben, sonst wiederholt `appRetryPolicy` jeden
Fehlerfall viermal mit Verzoegerung und die Tests werden langsam.

**Golden Tests: bewusst nicht.** Der Auth-Screen ist wegen `Random()` nicht
reproduzierbar, die UI ist noch im Fluss, und Goldens rendern
plattformabhaengig leicht unterschiedlich (Fehlalarme in CI). Lohnt sich erst
mit einem stabilen Design-System.

- [x] `mocktail` als dev_dependency

**Reine Logik** (kein Mocking noetig):

- [x] `test/core/error/dio_error_mapper_test.dart` - tabellengetrieben ueber
      Statuscodes und `DioExceptionType`, plus zwei Regeln, die die Tabelle
      nicht abbildet: `cause` bleibt erhalten, und der Statuscode schlaegt den
      Typ (ein 404 ist kein Netzwerkfehler)
- [x] `test/core/error/retry_policy_test.dart` - 401/404 brechen ab, sonst
      Backoff bis `_maxRetries`. Wartezeiten ausgeschrieben statt nachgerechnet,
      sonst prueft der Test dieselbe Formel, die er absichern soll
- [x] `test/features/user_profile/domain/username_test.dart` - leer ist
      `empty` und nicht `tooShort` (Reihenfolge der Pruefungen), und gezaehlt
      wird nach dem Trimmen

**Redirect** (wertvollster Fall: drei Gates x laden/Fehler/Daten):

- [x] Redirect-Closure aus `app_router.dart` in `lib/routing/redirect.dart`
      ausgelagert. Nimmt `AsyncValue`s entgegen, nicht ausgepackte Werte -
      "laedt noch" und "Fehler" fuehren zu anderem Verhalten als "Daten da".
      Dabei fiel auf, dass die import_lint-Regel fuer `routing/` die eigene
      Schicht nicht erlaubte; ergaenzt
- [x] `test/routing/redirect_test.dart` - 15 Faelle, u. a. die
      Redirect-Schleifen-Bremse, "Profil-Ladefehler schickt NICHT zum
      Anlegen" und die Reihenfolge der drei Gates

**Mit `mocktail`:**

- [x] `test/core/user/user_repository_impl_test.dart` - 404 -> `null`, sonst
      weiterwerfen. Fehler werden ueber `thenAnswer((_) async => throw ...)`
      gemeldet: `thenThrow` wirft synchron, was `createUser` (reicht den
      Future durch) anders trifft als die Realitaet
- [x] `test/core/auth/auth_repository_impl_test.dart` -
      `isNoCredentialsFound`/`isNoRefreshTokenFound` -> `null`, sonst
      weiterwerfen. `CredentialsManagerException` wird echt gebaut, nicht
      gemockt - die Getter pruefen `code`-Strings, ein Mock haette genau die
      Zuordnung uebersprungen
- [x] `test/features/user_profile/presentation/profile_setup_viewmodel_test.dart`
      - gemockt wird das Repository, nicht der Notifier, damit die Kette
      "Repository wirft -> AsyncError -> hasSubmitError" wirklich laeuft.
      Dabei `userRepositoryProvider` von `Provider<UserRepositoryImpl>` auf
      `Provider<UserRepository>` korrigiert (wie `authRepositoryProvider`)

**Widget-Tests** - nur dort, wo Verhalten steckt. Reine Layout-Assertions
("steht der Text da") brechen bei jeder Aenderung und finden nichts:

- [x] `test/helpers/pump_app.dart` - `ProviderScope` + `MaterialApp` mit
      `AppLocalizations`-Delegates. Locale fest auf Deutsch, sonst entscheidet
      der ausfuehrende Rechner ueber die gerenderten Texte
- [x] `AsyncValueView`: vorhandener Wert bleibt bei Fehler/Refresh stehen.
      `copyWithPrevious` ist `@internal`, der Zustand entsteht im Test also
      ueber einen echten Provider - naeher an der Realitaet als zusammengebaut
- [x] `ProfileSetupSection`: Fehlertext erst nach Submit, Submit-Fehler
      sichtbar. Prueft gegen echte Texte, damit die Kette Enum -> ARB ->
      gerendert mit abgedeckt ist
- [x] Consent-Schalter im `UserProfileSection`: spiegelt gespeicherten
      Zustand, schreibt beim Umschalten tatsaechlich weg (sonst waere der
      Widerruf nach dem naechsten Start weg), gesperrt waehrend des Schreibens

Nicht abgedeckt und bewusst so: `HomeSection` (kein Verhalten ausser Text
anzeigen), die Pages (reine Komposition), `AuthSection` (`Random()`),
`app_provider_observer` (braucht initialisiertes Firebase).

- [x] `flutter analyze`, `import_lint`, `dart format`, `flutter test` (77) -
      alles gruen

- [ ] `integration_test` erst, wenn es einen durchgehenden Flow gibt

---

## L) CI (GitHub Actions) ✅

Zuletzt, damit die Pipeline gleich den vollständigen Satz inkl. Tests prüft.

- [x] Workflow `.github/workflows/ci.yml`: Version via
      `flutter-version-file: .fvmrc` – das unterstützt
      `subosito/flutter-action@v2` direkt, also kein fvm auf dem Runner nötig
      und die Pinnung gilt trotzdem. Dann `pub get`,
      `dart format --set-exit-if-changed`, `flutter analyze`,
      `dart run import_lint`, `flutter test`
- [x] Alle Checks mit `if: ${{ !cancelled() }}` – sonst sieht man pro Push
      nur das erste Problem
- [x] Kein Java-/Android-SDK-Setup: ohne APK-Build braucht keiner der Checks
      die Android-Toolchain, das spart Minuten pro Lauf
- [x] `concurrency`-Gruppe: ältere Läufe desselben Branches werden abgebrochen
- [x] Trigger: Push auf alle Branches + PRs auf `main`; SDK-Caching an.
      Coverage bewusst nicht – bei einem Ein-Personen-Projekt vor allem eine
      Zahl, die niemand liest
- [x] Keine Build-Jobs. Ein signiertes Release-APK bräuchte Signing-Secrets;
      lohnt erst, wenn wirklich verteilt wird

**Beim ersten Lauf prüfen** (von lokal aus nicht testbar): ob die
Action-Versionen passen (`actions/checkout@v4` – die flutter-action-README
zeigt inzwischen `v6`) und ob der `.fvmrc`-Parser mit unserer Datei
zurechtkommt. Fallback wäre `flutter-version: 3.44.2` direkt im Workflow,
dann steht die Version aber doppelt.

**Bewusst nicht drin:** ein Codegen-Check (`build_runner` + `git diff
--exit-code`) wäre sinnvoll, weil die generierten Dateien eingecheckt sind
und driften können – kostet aber knapp eine Minute pro Lauf. Nachrüstbar.

---

## Abschluss

Nach E waren alle Checks grün; am Ende noch einmal vollständig durchlaufen:

- [ ] `fvm dart format .`
- [ ] `fvm flutter analyze`
- [ ] `fvm dart run import_lint`
- [ ] `fvm flutter test`
- [ ] `docs/architecture/feature-status.md` auf den Endstand bringen
