### Feature-Zuschnitt (Stand)

| Bereich/Feature                                 | Inhalt                                                                  | Stand                                                     |
| ------------------------------------------------|-------------------------------------------------------------------------|-----------------------------------------------------------|
| `core/`                                         | Netzwerk (dio), Theme, Auth-Session/Token, Fehlerbehandlung, Konstanten | teilweise vorhanden, Auth-Session-Migration offen         |
| `shared/widgets/`                               | Atomic-Design-Bausteine (atoms/molecules/organisms)                     | Ordner vorhanden, noch leer                               |
| `features/auth`                                 | Login/Logout via Auth0, Session-Handling                                | vorhanden, Umbau auf data/domain/presentation offen       |
| `features/user_profile`                         | Profil anlegen/bearbeiten (Avatar, Tiername, Farbe)                     | vorhanden                                                 |
| `features/home`                                 | Startbildschirm/Übersicht                                               | vorhanden (nur UI, keine Logik)                           |
| `features/games`, `features/games_kniffel`, ... | Spiele-Katalog + Session-Ergebnisse pro Spiel, analog zum Backend       | geplant                                                   |
| `features/sessions`                             | Gespielte Partien, Bilder, Kommentare, Likes                            | geplant                                                   |
| `features/social`                               | Freundschaften                                                          | geplant                                                   |
| `features/ratings`                              | Skill-Rating, Leaderboard                                               | geplant                                                   |
| `pages/`                                        | Screen-Komposition aus Sections                                         | noch anzulegen                                            |
| `routing/`                                      | GoRouter-Definition                                                     | vorhanden, liegt noch unter `core/routing/` (Umzug offen) |