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

## D) `routing/` auf Top-Level verschieben

- [ ] `lib/core/routing/app_router.dart` → `lib/routing/app_router.dart`
- [ ] Import in `lib/main.dart` anpassen
- [ ] Sonstige Importe von `core/routing/...` suchen & anpassen (`home_screen.dart`,
      `user_profile_screen.dart` – fallen aber ohnehin unter Punkt E weg)

---

## J) Aufräumen: leeres `core/network/`

- [ ] `lib/core/network/` (leer, Karteileiche aus initialem Scaffolding)
      entfernen – aktiver Dio-Code liegt in `core/dio/`

---

## K) Tooling/Doku-Abgleich

- [ ] `import_lint` als Dev-Dependency ergänzen, Basis-Regeln in
      `analysis_options.yaml` gemäß Architektur-Tabelle aus `CLAUDE.local.md`
      (Abhängigkeitsrichtung `core` ← `shared` ← `features` ← `pages` ← `routing`)
      – Feinschliff der Regeln erst nachdem `pages/`-Umbau (E) steht
- [ ] Diskrepanz `very_good_analysis` (dokumentiert) vs. `flutter_lints`
      (tatsächlich verwendet) klären: entweder Doku korrigieren oder Package
      wechseln
- [ ] `test/widget_test.dart` prüfen – vermutlich noch Flutter-Default-Template
      (Counter-App-Test), nicht mehr zutreffend → entfernen oder ersetzen

---

## B) Auth-Session-Architektur bereinigen

- [ ] Verschieben `features/auth/data/{auth_session.dart, auth_service.dart,
      auth_repository.dart, auth_repository_impl.dart,
      auth_session_provider.dart}` → `lib/core/auth/`
- [ ] `features/auth/presentation/*` importiert die core-Provider direkt (kein
      eigenes `data/` mehr nötig für den Login-Screen)
- [ ] **Toter Code entfernen:** `features/auth/presentation/auth_viewmodel.dart`
      (`AuthViewModel`/`authViewModelProvider`) – ungenutzte Dopplung von
      `authSessionProvider`
- [ ] Neu: `core/dio/auth_interceptor.dart` – `AuthInterceptor extends
      QueuedInterceptor`, `AuthService` per Konstruktor injiziert (kein Ref/
      Riverpod in der Klasse selbst, nur in der Wiring-Provider-Funktion).
      Liest Token direkt über `AuthService.getCredentials()` (Auth0 refresht
      selbst), mutiert **nicht** mehr den `authSessionProvider`-State
- [ ] `dio_provider.dart` verdrahtet nur noch den `AuthInterceptor`
- [ ] `authSessionProvider` aktualisiert nur noch bei echten Auth-Events
      (Login/Logout/App-Start), nicht mehr pro Request
- [ ] **Router-Refresh-Fix:** `onAuthStateChangedProvider` (in
      `auth_repository_impl.dart`) und `onUserStateChangedProvider` (in
      `user_repository_impl.dart`) samt der beiden `StreamController<bool>`
      entfernen. Stattdessen `refreshListenable` am `GoRouter` direkt aus
      `authSessionProvider`/`userProvider` speisen (offizielles
      Riverpod+go_router-Pattern, z. B. via `Raw<ValueNotifier<T>>` oder einer
      Notifier-Klasse, die `Listenable` implementiert)
- [ ] `main.dart`: manuelle `ref.listen(...).router.refresh()`-Aufrufe entfernen
      (werden durch `refreshListenable` überflüssig)
- [ ] **Fehlerbehandlung schärfen:** breites `catch (e)` in
      `auth_repository_impl.dart` (`getExistingSession`) und
      `user_repository_impl.dart` (`getCurrentUser`, `createUser`) – aktuell
      wird jeder Fehler (auch Netzwerkfehler) still zu `null` degradiert, was
      der Router als "kein Profil" fehlinterpretiert. Unterscheiden: echtes
      "nicht vorhanden" vs. technischer Fehler (ggf. mit `logger`-Package
      loggen statt zu schlucken)

---

## C) `domain/`-Layer nachziehen

- [ ] `features/user_profile/domain/username.dart`: Validierungsregel aus
      `profile_setup_viewmodel.dart` (`_validate`, Zeilen 36-44) hierher
      verschieben (Value-Object oder reine Validierungsfunktion); ViewModel
      ruft nur noch auf
- [ ] `features/auth/domain/`: prüfen, ob es überhaupt fachliche Regeln gibt
      (Login/Logout hat vermutlich keine) – kein Zwang, leer lassen falls
      nicht zutreffend

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
