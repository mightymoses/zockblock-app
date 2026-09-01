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

## Abschluss

- [x] `fvm flutter analyze` – keine Findings
- [x] `fvm dart run import_lint` – keine Findings
- [x] `fvm flutter test` – keine Testdateien vorhanden (Tests folgen separat)
- [x] Kurze Erklärung der wichtigsten Entscheidungen (wie im Workflow vorgesehen)
