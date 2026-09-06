### Feature-Zuschnitt (Stand)

| Bereich/Feature                                 | Inhalt                                                                 | Stand                                                                      |
| ------------------------------------------------|------------------------------------------------------------------------|----------------------------------------------------------------------------|
| `core/`                                         | Netzwerk (dio), Auth-Session/Token, aktueller Nutzer, Fehler, Theme, Config | vorhanden; Logging und Konstanten fehlen noch                          |
| `shared/widgets/`                               | Atomic-Design-Bausteine (atoms/molecules/organisms)                    | `AppFilledButton`; `ErrorView`/`AsyncValueView`; `AppPageScaffold`          |
| `features/auth`                                 | Login/Logout via Auth0                                                 | vorhanden; `data/` ist nach `core/auth/` gewandert, `domain/` bewusst leer  |
| `features/user_profile`                         | Profil anlegen/bearbeiten (Avatar, Tiername, Farbe)                    | vorhanden (`domain/` + `presentation/`); Datenzugriff liegt in `core/user/` |
| `features/home`                                 | Startbildschirm/Übersicht                                              | vorhanden (nur UI, keine eigene Logik)                                     |
| `features/games`, `features/games_kniffel`, ... | Spiele-Katalog + Session-Ergebnisse pro Spiel, analog zum Backend      | geplant                                                                     |
| `features/sessions`                             | Gespielte Partien, Bilder, Kommentare, Likes                           | geplant                                                                     |
| `features/social`                               | Freundschaften                                                         | geplant                                                                     |
| `features/ratings`                              | Skill-Rating, Leaderboard                                              | geplant                                                                     |
| `pages/`                                        | Screen-Komposition aus Sections                                        | vorhanden, alle vier Routen komponiert                                      |
| `routing/`                                      | GoRouter-Definition                                                    | vorhanden auf Top-Level                                                     |

### Bekannte offene Punkte

- `features/consent/` ist ein fragwuerdiger Zuschnitt: nur `presentation/`,
  kein `domain/`, keine `data/` – nach eigener Regel das Warnsignal fuer "kein
  echtes Feature". Wahrscheinlich besserer Schnitt spaeter: ein
  `features/settings/` bzw. `features/privacy/`, das die Frage beim ersten
  Start *und* den Widerrufs-Schalter besitzt (der liegt derzeit im
  Nutzerprofil). `core/consent/` bleibt, wo es ist – der Router braucht es.
  Voraussetzung ist eine Entscheidung ueber den Feature-Zuschnitt insgesamt.
- Keine Tests vorhanden (`mocktail` ist noch nicht mal Dependency), keine CI.
- Kein Logging/Crash-Reporting (`logger`, Crashlytics) – Fehler werden zwar
  angezeigt, aber nirgends festgehalten.
- Router-Redirect schickt bei `authSession`-Fehler auf `/auth`; bei reinem
  Netzwerkfehler loggt das einen eingeloggten Nutzer optisch aus.
- `shared_preferences`/`drift` und Firebase (FCM) noch nicht eingebunden,
  bisher auch nicht gebraucht.
