### Feature-Zuschnitt (Stand)

| Bereich/Feature                                 | Inhalt                                                                                                       | Stand                                                                      |
| ------------------------------------------------|--------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------|
| `core/`                                         | Netzwerk (dio), Auth-Session, aktueller Nutzer, Fehler, Logging, Einwilligung, Crash-Reporting, Theme, Config | vorhanden; Konstanten fehlen noch                                          |
| `shared/widgets/`                               | Atomic-Design-Bausteine (atoms/molecules/organisms)                                                          | `AppFilledButton`; `ErrorView`/`AsyncValueView`; `AppPageScaffold`          |
| `features/auth`                                 | Login/Logout via Auth0                                                                                       | vorhanden; `data/` ist nach `core/auth/` gewandert, `domain/` bewusst leer  |
| `features/user_profile`                         | Profil anlegen/bearbeiten (Avatar, Tiername, Farbe)                                                          | vorhanden (`domain/` + `presentation/`); Datenzugriff liegt in `core/user/` |
| `features/consent`                              | Einwilligung in Absturzberichte beim ersten Start                                                            | vorhanden; Zuschnitt fragwürdig, siehe unten                               |
| `features/home`                                 | Startbildschirm/Übersicht                                                                                    | vorhanden (nur UI, keine eigene Logik)                                     |
| `features/games`, `features/games_kniffel`, ... | Spiele-Katalog + Session-Ergebnisse pro Spiel, analog zum Backend                                            | geplant                                                                     |
| `features/sessions`                             | Gespielte Partien, Bilder, Kommentare, Likes                                                                 | geplant                                                                     |
| `features/social`                               | Freundschaften                                                                                               | geplant                                                                     |
| `features/ratings`                              | Skill-Rating, Leaderboard                                                                                    | geplant                                                                     |
| `pages/`                                        | Screen-Komposition aus Sections                                                                              | vorhanden, alle fünf Routen komponiert                                     |
| `routing/`                                      | GoRouter-Definition + `resolveRedirect` als reine Funktion                                                   | vorhanden auf Top-Level                                                     |

### Qualitätssicherung

- 77 Tests: Redirect-Gates, beide Repository-Fehlerabbildungen,
  `ProfileSetupViewModel` + Section, `AsyncValueView`, Consent-Schalter, dazu
  die reinen Funktionen (dio-Fehler-Mapping, Retry-Policy, Nutzername-Regeln).
  Golden Tests bewusst nicht, Begründung in Checklisten-Punkt I.
- CI (`.github/workflows/ci.yml`) prüft bei jedem Push Format, `analyze`,
  Schichtgrenzen und Tests. Die Flutter-Version kommt aus `.fvmrc`.
- `import_lint` erzwingt die Abhängigkeitsrichtung inklusive `pages`/`routing`.

### Bekannte offene Punkte

- **iOS wurde nie gebaut** und ist entsprechend unvollständig: es fehlen
  `GoogleService-Info.plist`, `FirebaseCrashlyticsCollectionEnabled = false`
  in der `Info.plist` und – für Universal Links ab iOS 17.4 – die
  Associated-Domains-Capability plus Apple Team ID im Auth0-Dashboard.
  Unterhalb 17.4 greift der Custom-Scheme-Fallback, der Login ist dort also
  nicht generell kaputt. Alles zusammen beim ersten Mac-Build erledigen.
- `features/consent/` ist ein fragwürdiger Zuschnitt: nur `presentation/`,
  kein `domain/`, keine `data/` – nach eigener Regel das Warnsignal für "kein
  echtes Feature". Wahrscheinlich besserer Schnitt später: ein
  `features/settings/` bzw. `features/privacy/`, das die Frage beim ersten
  Start *und* den Widerrufs-Schalter besitzt (der liegt derzeit im
  Nutzerprofil). `core/consent/` bleibt, wo es ist – der Router braucht es.
  Voraussetzung ist eine Entscheidung über den Feature-Zuschnitt insgesamt.
- Router-Redirect schickt bei `authSession`-Fehler auf `/auth`; bei reinem
  Netzwerkfehler loggt das einen eingeloggten Nutzer optisch aus. Zu klären,
  ob `NetworkException` dort wie `loading` behandelt werden soll.
- Vor einer Veröffentlichung: Datenschutzerklärung, Play-Data-Safety-Formular,
  Apple Privacy Nutrition Labels.
- `drift` und Firebase Cloud Messaging noch nicht eingebunden, bisher auch
  nicht gebraucht. `shared_preferences` ist seit der Einwilligung im Einsatz.
- `integration_test` erst, wenn es einen durchgehenden Flow gibt.
