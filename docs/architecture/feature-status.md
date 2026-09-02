### Feature-Zuschnitt (Stand)

| Bereich/Feature                                 | Inhalt                                                                 | Stand                                                                      |
| ------------------------------------------------|------------------------------------------------------------------------|----------------------------------------------------------------------------|
| `core/`                                         | Netzwerk (dio), Auth-Session/Token, Theme, Config                      | vorhanden; Fehlerbehandlung/Logging und Konstanten fehlen noch             |
| `shared/widgets/`                               | Atomic-Design-Bausteine (atoms/molecules/organisms)                    | `AppFilledButton` (atom), `AppPageScaffold` (organism); molecules leer      |
| `features/auth`                                 | Login/Logout via Auth0                                                 | vorhanden; `data/` ist nach `core/auth/` gewandert, `domain/` bewusst leer  |
| `features/user_profile`                         | Profil anlegen/bearbeiten (Avatar, Tiername, Farbe)                    | vorhanden, vollständige Schichtenkette; bisher nur Anlegen                  |
| `features/home`                                 | Startbildschirm/Übersicht                                              | vorhanden (nur UI, keine eigene Logik)                                     |
| `features/games`, `features/games_kniffel`, ... | Spiele-Katalog + Session-Ergebnisse pro Spiel, analog zum Backend      | geplant                                                                     |
| `features/sessions`                             | Gespielte Partien, Bilder, Kommentare, Likes                           | geplant                                                                     |
| `features/social`                               | Freundschaften                                                         | geplant                                                                     |
| `features/ratings`                              | Skill-Rating, Leaderboard                                              | geplant                                                                     |
| `pages/`                                        | Screen-Komposition aus Sections                                        | vorhanden, alle vier Routen komponiert                                      |
| `routing/`                                      | GoRouter-Definition                                                    | vorhanden auf Top-Level                                                     |

### Bekannte offene Punkte

- Zustand des aktuellen Nutzers (`userProvider`) liegt noch in
  `features/user_profile/data/`, wird aber vom Router und von `features/home`
  gebraucht. Vermutlich gehört er analog zu `core/auth/` nach `core/user/`.
  Bis dahin steht in `analysis_options.yaml` eine kommentierte
  import_lint-Ausnahme.
- Keine Tests vorhanden (`mocktail` ist noch nicht mal Dependency), keine CI.
- Keine zentrale Fehlerbehandlung/Logging (`logger`, Crashlytics) – ein
  fehlgeschlagener Request bleibt außerhalb des Profil-Formulars unsichtbar.
- `shared_preferences`/`drift` und Firebase (FCM) noch nicht eingebunden,
  bisher auch nicht gebraucht.
