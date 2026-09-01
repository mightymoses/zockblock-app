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

## F) SVG → WebP für animierte Grafiken

- [ ] `assets/graphics/zock.svg`, `block.svg` (in `MarqueeRow`) als WebP
      exportieren; `SvgPicture.asset(..., colorFilter: ...)` →
      `Image.asset(..., color: color, colorBlendMode: BlendMode.srcIn)`
- [ ] `assets/graphics/{Zock,Block}-{Links,Rechts}_{Bright,Dark}.svg` (in
      `SpinningCircle`) als WebP exportieren, `SvgPicture.asset` → `Image.asset`
- [ ] `Pfeil-Links.svg`/`Pfeil-Rechts.svg` bleiben SVG (einmalig, nicht animiert)
- [ ] Nach Umstellung: kurzer Performance-Check auf echtem Gerät (Auth-Screen,
      Performance-Overlay), ob spürbar flüssiger

---

## E) `pages/`-Schicht einführen

Router soll ausschließlich aus `pages/` importieren. Pro bestehendem
`*_screen.dart`: Scaffold-Chrome → `lib/pages/<name>_page.dart`, Inhalt →
`features/<feature>/presentation/<name>_section.dart`. Folgende Cleanups aus
dem Review werden beim jeweiligen Screen direkt mit erledigt (nicht separat).

- [ ] **auth:** `AuthScreen` → `pages/auth_page.dart` + `features/auth/presentation/auth_section.dart`
- [ ] **home:** `HomeScreen` → `pages/home_page.dart` + `features/home/presentation/home_section.dart`
  - dabei: `ref.watch(routerProvider).go(...)` → `context.go(...)`
  - dabei: hardcodierte Farben/Fonts → Theme-Tokens bzw. neuer
    `shared/widgets/atoms`-Baustein (z. B. `AppFilledButton` für den
    wiederholten Button-Style)
  - dabei: hardcodierte deutsche Strings → `AppLocalizations`
- [ ] **profile-setup:** `ProfileSetupScreen` → `pages/profile_setup_page.dart` + `features/user_profile/presentation/profile_setup_section.dart`
- [ ] **user-profile:** `UserProfileScreen` → `pages/user_profile_page.dart` + `features/user_profile/presentation/user_profile_section.dart`
  - dabei: `context.go(...)` statt `ref.watch(routerProvider).go(...)`
  - dabei: hardcodierte Farben/Fonts → Theme-Tokens / `AppFilledButton`
  - dabei: hardcodierte Strings → `AppLocalizations` (inkl. Tippfehler "Nuzterprofil")
- [ ] `lib/routing/app_router.dart` (siehe D): Importe auf `pages/*` umstellen

---

## Abschluss

- [ ] `fvm flutter analyze`
- [ ] `fvm dart run import_lint`
- [ ] `fvm flutter test`
- [ ] Kurze Erklärung der wichtigsten Entscheidungen (wie im Workflow vorgesehen)
