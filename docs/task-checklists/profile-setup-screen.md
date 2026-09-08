# Profil-Anlegen-Screen (Onboarding) ausbauen

Kontext: Der bestehende `/profile-setup`-Screen fragt bisher nur einen Nutzernamen ab. Laut
Design soll er das komplette Profil erfassen: Avatar (Tier + Farbe **oder** Foto), Username und
zwei Bio-Zeilen. Das Backend ist dafür bereits fertig (siehe
`zockblock-backend/docs/task-checklists/user-profile-onboarding.md`).

## Design (Kurzfassung)

- **Oberer Bereich** – Hintergrundfarbe = die vom Nutzer gewählte Avatar-Farbe (Default:
  `colorScheme.primary`): Topbar, Umschalter `Tier | Foto`, großes Avatar-Bild rechts, links
  darunter Farb-Button und Foto-Kachel. Jedes Element mit Bearbeiten-Symbol öffnet ein
  Bottom-Sheet.
- **Unterer Bereich** – dunkler Block mit drei Feldern als abgerundete Karten, je mit
  kleinem Label und Zeichen-Zähler: `USERNAME` (x/20), `BIO 1` (x/40), `BIO 2` (x/80).
- **Fuß** – breiter Primär-Button "Spieler anlegen".

## Backend-Schnittstelle (vorhanden, nichts zu tun)

| Endpoint | Inhalt |
| --- | --- |
| `POST /users/` | `username`, `animalAssetName`, `avatarColor` (int), `bioLine1`, `bioLine2`, `avatarUrl` |
| `PATCH /users/current` | dieselben Felder optional; explizites `null` löscht |
| `GET /users/username-availability?username=` | `{ isAvailable: bool }` |
| `POST /users/current/avatar-upload-url` | `{ contentType }` → `{ uploadUrl, avatarUrl }` |

Fehler: **409** Username vergeben, **400** ungültige `avatarUrl` (nicht aus unserem Upload-Flow),
**422** Format-/Längenverstoß.

## Entscheidungen aus der Planung

- **Shared-First:** Alles, was keinen Fachbezug hat, wird als Baustein in `shared/widgets/`
  gebaut – Buttons, Icon-Buttons, Eingabefelder, Topbar, Bottom-Sheet-Gerüst. Ziel ist ein
  app-weit einheitliches Aussehen, nicht die Wiederverwendung in genau diesem Screen. Die
  konkrete Aufteilung steht in Abschnitt 10/11.
- **Kein Schließen-Button im Onboarding.** Der einzige Weg weiter ist der Anlegen-Button (der
  Router hält ohnehin auf `/profile-setup`, solange kein Profil existiert). Die Topbar bekommt
  deshalb ein *optionales* `leading` – im späteren Bearbeiten-Modus sitzt dort das X.
- **Farben:** Das Grün im Design ist die *gewählte Nutzerfarbe*, kein neuer Theme-Ton. Default ist
  `colorScheme.primary`; sobald der Nutzer eine Farbe wählt, färbt sich der Kopfbereich um.
- **Freie Farbwahl statt fester Palette:** Farbton-Balken + Helligkeits-Balken (HSV), dazu eine
  Reihe Presets als Schnellauswahl. Damit ist `avatarColor` als ARGB-Int endgültig gesetzt – ein
  Palettenindex wäre gar nicht mehr abbildbar.
- **Die Farbe muss aktiv gewählt werden.** `avatarColor` startet als `null`; der Kopfbereich wird
  dann in `colorScheme.primary` dargestellt, das ist aber *keine* Auswahl – beim Submit fehlt die
  Farbe und wird rot markiert. Der Farb-Button zeigt im ungewählten Zustand das Farbrad aus dem
  Design, danach den gewählten Volltonkreis.
- **Das Tier ist beim Öffnen zufällig vorbelegt.** Es kann also nie fehlen, der Nutzer startet mit
  einem fertigen Avatar und muss nur noch die Farbe setzen. Die Vorbelegung passiert einmalig beim
  Aufbau des ViewModels, nicht bei jedem Rebuild.
- **Tier-Bilder werden im App-Bundle ausgeliefert**, nicht aus R2 nachgeladen (bestätigt die
  Backend-Entscheidung). Avatare erscheinen später in jedem Feed, jeder Rangliste und jeder
  Sitzung – aus R2 hieße dort überall Netzwerk-Nachladen, Platzhalter beim Scrollen und ein
  kaputtes Bild ohne Verbindung. Gespeichert wird ohnehin nur der Key, ein späterer Wechsel auf
  Nachladen bliebe also möglich, ohne Daten zu migrieren.
- **Bio-Längen im Frontend 40/80**, obwohl das Backend 100/100 erlaubt – das Frontend darf
  strenger sein, das Backend bleibt unverändert.
- **Foto-Upload entkoppelt:** Sobald ein Foto gewählt und zugeschnitten ist, holt die App sofort
  eine Presigned-URL und lädt im Hintergrund zu R2 hoch. Der Submit schickt nur noch die fertige
  `avatarUrl` – kein Warten beim Abschluss.
- **Foto-Qualität ist explizit ein Ziel** (Vorgänger-App hatte schlechte Fotos): beim Auswählen
  *keine* Skalierung oder Kompression durch `image_picker`, erst der Cropper erzeugt das
  Endergebnis mit definierter Größe und Qualität.
- **Der `Tier | Foto`-Umschalter ist ein eigener gespeicherter Wert** (`avatarMode`), kein
  Nebeneffekt davon, ob ein Foto existiert. Beide Wertepaare bleiben erhalten, der Nutzer schaltet
  frei hin und her, ohne dass das Foto verloren geht. **Setzt eine Backend-Erweiterung voraus,
  siehe Abschnitt 0.**
- **Nur der Onboarding-Modus wird gebaut.** Ein späterer Bearbeiten-Modus (`PATCH`) und das vom
  Backend vorbereitete verwaltete Profil (`owner_user_id`) werden *mitgedacht*, aber nicht
  implementiert: Domain-Modell, Sheets und Widgets kennen den Unterschied create/patch nicht,
  die einzige betroffene Stelle ist `submit()` im ViewModel. Erweiterung später über einen
  `ProfileFormMode`-Parameter an der Section (Routen-Parameter sind erlaubt).
- **Avatar-Fachlichkeit liegt in `core/user/`, nicht im Feature:** Der Avatar wird künftig überall
  angezeigt (Home, Sessions, Freunde, Leaderboard) und die Felder stecken bereits in
  `core/user/user.dart`. Rein *formularbezogene* Regeln (Username-Format, Bio-Längen,
  Entwurfszustand) bleiben in `features/user_profile/domain/`.
- **`shared/` bleibt fachfrei:** Das Avatar-Widget nimmt primitive Parameter (Bild, Farbe, Größe)
  entgegen; einen `Avatar` aus `core/user/` kennt nur ein zusätzlicher Convenience-Konstruktor.
  Damit bleibt die Regel "shared hat keinen Fachbezug" gewahrt und andere Features können das
  Widget trotzdem benutzen.

## 0. Voraussetzung: `avatarMode` im Backend – **erledigt**

Das Backend kannte zunächst keinen Umschalter: Die Anzeigeart ergab sich allein daraus, *ob* ein
Foto existiert ("`avatar_url` überschreibt den Tier-Avatar"). Der `Tier | Foto`-Schalter hätte sich
so nur nachbilden lassen, indem beim Wechsel auf "Tier" die `avatar_url` gelöscht wird – das Foto
wäre weg gewesen.

- [x] Nachgezogen im Backend, Commit `52d220c` (`feat(users): add avatar_mode`):
      Spalte mit Default `"animal"`, Migration `77fa0956ea17` mit `server_default`,
      `AVATAR_MODES = Literal["animal", "photo"]` in allen drei Schemas,
      `InvalidAvatarModeException` (400) wenn Modus `photo` ohne `avatar_url` gesetzt wird
- [x] Verhalten geprüft: `_validate_avatar_mode` läuft in `update_user` **nach** dem Anwenden der
      Änderungen – Foto und Modus dürfen also in einem PATCH zusammen kommen, und der Wechsel auf
      `animal` lässt die `avatar_url` unangetastet

## 1. Assets: Tier-Bilder

**Quelle:** `C:\Users\knaue\Pictures\tier-icons\Original` – **53** PNGs, je 1024×1024, RGBA mit
Transparenz, deutsche Dateinamen. Zusammen 44 MB, als PNG also nicht bündelbar. (Der ältere
Android-Ordner `Spieleblock/.../res/drawable` enthält nur 52 Bilder in 512×512: dort fehlt `Schaf`
und `Schlange` hieß `cobra`. Wir nehmen die Originale – vollständiger und höher aufgelöst.)

- [x] Messreihe über **alle 53** Bilder, WebP `-quality 90` aus den 1024er-Originalen skaliert:

      | Zielgröße | klein | mittel | groß   | gesamt      |
      | ----------| ------| -------| -------| ------------|
      | **512²**  | 14 KB | 61 KB  | 76 KB  | **2,4 MB**  |
      | 768²      | 25 KB | 109 KB | 134 KB | 4,2 MB      |

      Verlustfrei war vorab schon ausgeschieden (~8 MB nur für Tierbilder).

- [x] **Entscheidung: 768², `-quality 90`.** Schärfe geht hier vor App-Größe: 512² wäre nur bis
      ~170 dp Darstellungsgröße pixelgenau, und im Kopfbereich ist das Tier größer. Kosten:
      4,2 MB statt 2,4 MB.
- [x] **Entscheidung: englische Keys**, klein und `snake_case` – vermeidet Umlaute in Dateinamen
      und Datenbankwerten. Mapping siehe unten.
- [x] **Entscheidung: `Schaf` kommt nicht mit** (52 Tiere), `Schlange` heißt `snake`.
- [x] `Blauwal` heißt `whale`, nicht `blue_whale`: Ein Unterstrich im Enum-Wert verstößt gegen
      `constant_identifier_names`, und der Enum-Name muss dem Dateinamen entsprechen. `whale` ist
      eindeutig, ein zweiter Wal ist nicht im Satz (`orca` heißt orca).
- [x] Konvertiert nach `assets/images/animals/`: 52 Dateien, 768×768, `yuva420p` (Transparenz
      erhalten), zusammen 4,2 MB. Skript liegt im Scratchpad (`convert_animals.py`), die Quelle
      wurde nur gelesen.
- [x] `pubspec.yaml`: `assets/images/animals/` ergänzt – als **eigener** Eintrag, denn
      `assets/images/` erfasst Unterordner nicht mit
- [x] Original-PNGs nicht eingecheckt (liegen ausserhalb des Repos)

**Namens-Mapping** (deutscher Dateiname → `animalAssetName`):

| | | | |
| --- | --- | --- | --- |
| Adler → `eagle` | Affe → `monkey` | Anglerfisch → `anglerfish` | Biber → `beaver` |
| Biene → `bee` | Blauwal → `whale` | Bär → `bear` | Delfin → `dolphin` |
| Drache → `dragon` | Eichhörnchen → `squirrel` | Elefant → `elephant` | Esel → `donkey` |
| Eule → `owl` | Faultier → `sloth` | Frosch → `frog` | Fuchs → `fox` |
| Giraffe → `giraffe` | Hahn → `rooster` | Hai → `shark` | Hase → `hare` |
| Hirsch → `deer` | Hund → `dog` | Katze → `cat` | Krake → `octopus` |
| Kuh → `cow` | Lemur → `lemur` | Löwe → `lion` | Maus → `mouse` |
| Möwe → `seagull` | Nashorn → `rhino` | Nilpferd → `hippo` | Orca → `orca` |
| Otter → `otter` | Panda → `panda` | Panther → `panther` | Papagei → `parrot` |
| Pferd → `horse` | Phoenix → `phoenix` | Pinguin → `penguin` | Qualle → `jellyfish` |
| Rabe → `raven` | Schildkröte → `turtle` | Schlange → `snake` | Schnecke → `snail` |
| Schwein → `pig` | Seehund → `seal` | Seepferdchen → `seahorse` | Spinne → `spider` |
| Tapir → `tapir` | Tiger → `tiger` | Wolf → `wolf` | Ziege → `goat` |

## 2. Dependencies

- [x] `image_cropper: ^12.2.1`, `image_picker: ^1.2.3`
- [x] `UCropActivity` in der `AndroidManifest.xml` registriert. Debug-APK gebaut: der Merge läuft
      durch, `@style/Theme.AppCompat.Light.NoActionBar` löst auf (AppCompat kommt transitiv über
      uCrop). Keine zusätzliche Berechtigung nötig – der System-Photo-Picker wählt ausserhalb
      unserer App aus.
- [x] `NSCameraUsageDescription` und `NSPhotoLibraryUsageDescription` in der `Info.plist`, mit
      konkreter Zweckangabe (generische Texte lehnt Apple im Review ab). Nur deutsch;
      mehrsprachig ginge über `InfoPlist.strings` je Sprachordner – offen fürs erste Mac-Build.
      `image_cropper` braucht iOS-seitig laut Doku keine Konfiguration.
- [x] Lokal geprüft: Format, `flutter analyze`, `import_lint`, 77 Tests – alles grün
- [ ] **CI-Lauf auf GitHub steht noch aus**: Der Branch ist nicht gepusht, und die
      Workflow-Datei hat mit den Codegen-Schritten selbst Änderungen bekommen, die noch nie auf
      einem Runner gelaufen sind. Beim ersten Push draufschauen.

**Warum diese Pakete:** `image_picker` nutzt auf Android ab API 33 den System-Photo-Picker und auf
iOS `PHPicker` – das ist die "richtige" native Galerie inklusive Berechtigungsverhalten. Der
`image_cropper` setzt auf uCrop (Android) beziehungsweise TOCropViewController (iOS) auf. Das
`camera`-Paket wäre die Alternative für eine eigene Kamera-Oberfläche, ist hier aber zu viel: wir
brauchen keine eigene Aufnahme-UI, nur ein gutes Ergebnisbild.

**Kein Farb-Picker-Paket:** Farbton- und Helligkeits-Balken bauen wir selbst (siehe
`app_color_slider.dart` in Abschnitt 10) – das sind zwei Verlaufsbalken auf `HSVColor`, überschaubar
und exakt im Design der App. Fallback, falls es doch fummelig wird: `flex_color_picker` oder
`flutter_hsvcolor_picker`.

## 3. `core/user/user.dart` erweitern

- [x] Felder ergänzt (bis auf `avatarMode` alle nullable, das Backend liefert sie so):
      `animalAssetName`, `avatarColor` (`int?`), `bioLine1`, `bioLine2`, `avatarUrl`,
      `avatarMode` (Enum `animal | photo`, Default `animal`)
- [x] Unbekannter `avatarMode` wird tolerant auf `animal` abgebildet – zwei verschiedene Fälle,
      zwei Annotationen: `@JsonKey(unknownEnumValue:)` gegen einen unbekannten *Wert* aus einer
      neueren Backend-Version, `@Default` gegen ein *fehlendes* Feld
- [x] Serialisierung im Generat verifiziert: camelCase passt ohne Umbenennungen,
      `$enumDecodeNullable(..., unknownValue: AvatarMode.animal) ?? AvatarMode.animal`
- [x] `avatar`-Getter ergänzt, der `Avatar.of` aufruft – dafür braucht die freezed-Klasse einen
      privaten Konstruktor (`const User._();`)
- [x] `createdAt`/`updatedAt` bewusst weggelassen: von der App nirgends gebraucht, unbekannte
      JSON-Schlüssel ignoriert der Generator beim Parsen
- [x] `analysis_options.yaml`: `**/*.g.dart` und `**/*.freezed.dart` von der Analyse ausgenommen.
      json_serializable erzeugt für Enums mit `unknownEnumValue` Code, den `very_good_analysis`
      rügt (`unnecessary_null_checks`, `specify_nonobvious_property_types`) – anpassen lässt er
      sich nicht, und `flutter analyze` bricht auch bei `info` ab

## 4. Avatar-Fachlichkeit in `core/user/` – **wird vor Abschnitt 3 umgesetzt**

Reihenfolge getauscht: `user.dart` braucht den Typ von `avatarMode`, der hier entsteht. Andersherum
müsste der Enum erst im DTO angelegt und später verschoben werden.

**Keine Farbregeln.** Ursprünglich waren hier eine `AvatarColor`-Klasse mit Default-Semantik und
Helligkeitsgrenzen geplant – beides gestrichen:

- Die Default-Semantik ist keine Logik, sondern zwei Einzeiler an Stellen, die es schon gibt: Das
  Formular wertet `avatarColor == null` als fehlend (`ProfileDraft.validate()`), die Anzeige macht
  `color ?? Theme.of(context).colorScheme.primary` – Letzteres braucht `BuildContext` und dürfte
  in `core/` ohnehin nicht stehen.
- Helligkeitsgrenzen sind unnötig: praktisch getestet, die Tiere bleiben auf jeder Farbe gut
  erkennbar, auch auf Schwarz und Weiß. Volle Farbwahl ohne Sonderbehandlung.
- Kontrast (helle oder dunkle Schrift auf der Nutzerfarbe) braucht keine eigene Funktion,
  `ThemeData.estimateBrightnessForColor` ist eingebaut. Falls uns deren Schwelle irgendwann nicht
  passt, gehört eine eigene nach `core/theme/` – Farbmathematik hat nichts mit Nutzern zu tun.
- Die Farb-Presets für die Schnellauswahl leben im Farb-Sheet des Features, nicht in `core/`:
  außerhalb des Sheets braucht sie niemand.

- [x] `core/user/animal_asset.dart`: `AnimalAsset` als Enum mit 52 Werten. Der Enum-Name ist
      zugleich Backend-Key und Dateiname, deshalb ohne Zuordnungstabelle. Dazu `assetPath`,
      `fromName(String?)` (tolerant, `null` bei unbekanntem Tier aus einer neueren
      Backend-Version) und `random([Random?])` für die Vorbelegung.
- [x] `core/user/avatar.dart`: `AvatarMode { animal, photo }` als schlichter Enum ohne
      JSON-Annotationen, plus `Avatar` als **versiegelte freezed-Union** aus `AnimalAvatar` und
      `PhotoAvatar`. Eine flache Klasse hätte in jedem Widget ein `photoUrl!` erzwungen; so ist
      der `switch` erschöpfend und ohne Null-Prüfung. Die Auswahl fällt einmal in `Avatar.of`,
      inklusive Rückfall aufs Tier, wenn der Modus `photo` ist, aber keine URL vorliegt.
      Kennt `User` **nicht**, sonst entstünde ein Import-Ring.
- [x] Kein Riverpod. `color` bleibt ein `int?` (ARGB) statt `Color`: So bleibt die Datei reines
      Dart und entspricht dem Wire-Format; die Umwandlung und der Rückfall auf
      `colorScheme.primary` passieren im Widget, das dafür ohnehin `BuildContext` braucht.

## 5. `core/user/user_service.dart` und Repository erweitern

- [ ] `user_service.dart`:
  - [ ] `updateCurrentUser(Map<String, Object?> changes)` → `PATCH /users/current`
  - [ ] `checkUsernameAvailability(String username, {CancelToken? cancelToken})` →
        `GET /users/username-availability`
  - [ ] `createAvatarUploadUrl(String contentType)` → `POST /users/current/avatar-upload-url`,
        Rückgabe als kleines DTO (`AvatarUpload` mit `uploadUrl` und `avatarUrl`)
- [ ] `user_repository.dart` und `user_repository_impl.dart` um dieselben drei Methoden erweitern
- [ ] `core/error/app_exception.dart`: `ConflictException` ergänzen (Username vergeben)
- [ ] `core/error/dio_error_mapper.dart`: `409 => ConflictException`
- [ ] `test/core/error/dio_error_mapper_test.dart` um den 409-Fall erweitern

## 6. `core/network/plain_dio_provider.dart` – Dio ohne Auth

- [ ] Zweiter `Dio` **ohne** `AuthInterceptor` und ohne `baseUrl`, nur für den PUT zur
      Presigned-URL
- [ ] Begründung als Doc-Comment: unser Auth0-Token darf nicht an Cloudflare gehen, und die
      Presigned-URL trägt ihre Signatur bereits in der Query
- [ ] Timeouts großzügiger als beim API-Client (Foto-Upload über Mobilfunk)

## 7. `features/user_profile/data/avatar_upload_service.dart`

- [ ] `uploadAvatar(File file, String contentType, {void Function(int, int)? onProgress})`:
      Presigned-URL über das `UserRepository` holen, dann `PUT` mit dem *exakt* signierten
      `Content-Type` über den Plain-Dio; gibt die spätere öffentliche `avatarUrl` zurück
- [ ] Erlaubte Typen entsprechen der Backend-Allowlist: `image/jpeg`, `image/png`, `image/webp`
- [ ] Fehler über `mapDioException` auf `AppException` abbilden
- [ ] `CancelToken` durchreichen, damit ein zweites gewähltes Foto den laufenden Upload abbricht
- [ ] Kein Riverpod im Konstruktor – der Provider liegt wie üblich im selben File

## 8. `features/user_profile/domain/` – Formularregeln

- [ ] `username.dart` erweitern: `maxLength = 20`, Backend-Regex spiegeln
      (`^[a-zA-Z0-9]+(?:[._-][a-zA-Z0-9]+)*$`), neue Fehlergründe `tooLong` und `invalidFormat`
      – damit der Nutzer den 422 nie zu sehen bekommt
- [ ] `bio_line.dart`: `maxLengthLine1 = 40`, `maxLengthLine2 = 80`, Validierung und Fehlergrund
- [ ] `profile_draft.dart`: der Formularzustand als reines Dart-Objekt – `username`, `bioLine1`,
      `bioLine2`, `animalAssetName`, `avatarColor`, `photoUrl`, `avatarMode` (`animal | photo`)
  - [ ] `validate()` gibt **alle** Fehler auf einmal zurück (`ProfileDraftErrors` mit einem Feld
        je Formularfeld), nicht nur den ersten – der Button soll auf einen Schlag alles markieren,
        was fehlt
  - [ ] `animalAssetName` ist beim Aufbau zufällig vorbelegt und damit nie leer; `avatarColor`
        startet als `null` und ist ein Pflichtfeld
  - [ ] Umsetzung in das, was gespeichert wird: **alle** Werte gehen raus – Tier, Farbe,
        `avatarUrl` (falls hochgeladen) und `avatarMode`. Kein Feld wird mehr abhängig vom Modus
        auf `null` gesetzt, genau dafür gibt es jetzt `avatarMode`.
- [ ] Bewusst kein `freezed`, solange das Objekt klein bleibt – ab etwa acht Feldern neu bewerten

## 9. `features/user_profile/presentation/` – Zustand und Validierung

- [ ] `username_availability_provider.dart`: `FutureProvider.autoDispose.family<bool, String>`
      nach dem offiziellen Riverpod-Muster (Dispose-Flag, `Future.delayed(500ms)`, `CancelToken`
      in `ref.onDispose`) – wird nur abgefragt, wenn die lokale Formatprüfung schon sauber ist,
      damit wir das Backend nicht bei jedem Tastendruck fragen
- [ ] `profile_form_viewmodel.dart` (ersetzt `profile_setup_viewmodel.dart`):
  - [ ] hält den `ProfileDraft`, die aktuellen `ProfileDraftErrors`, ein `showErrors`-Flag, den
        Upload-Status (`idle | uploading | done | failed`) und den Submit-Status
  - [ ] `updateUsername`, `updateBioLine1`, `updateBioLine2`, `selectAnimal`, `selectColor`,
        `setAvatarMode`
  - [ ] `pickPhoto(ImageSource source)`: auswählen, zuschneiden, Upload starten (bewusst ohne
        `await`, das Ergebnis landet im State)
  - [ ] `removePhoto()`: verwirft das Foto wirklich und schaltet auf `animal` zurück – das ist
        etwas anderes als `setAvatarMode(animal)`, das das Foto behält
  - [ ] `submit()`: validieren, `createUser`, den 409 als "Username vergeben" am Feld anzeigen
        statt als globalen Fehler
  - [ ] Fehler weiterhin als *Typen* im State, die Übersetzung passiert in der Section

**Validierungsverhalten** (bewusst festgelegt, weil es die halbe UX ausmacht):

| Regel | Verhalten |
| --- | --- |
| Wann wird geprüft? | Beim ersten Tippen auf den Anlegen-Button wird `showErrors` gesetzt. Danach validiert jedes Feld **live** bei jeder Änderung weiter. |
| Was wird markiert? | Alle fehlenden/ungültigen Felder gleichzeitig, nicht nur das erste. |
| Wie sieht das aus? | Eingabefelder: roter Rahmen, rotes Label, Meldung darunter. Avatar-Elemente (Tier/Farbe/Foto): roter Rahmen um die Vorschau-Kachel. |
| Pflichtfelder | Username (leer, zu kurz, zu lang, Format, bereits vergeben) und Farbe. Bio 1/2 sind optional, nur die Länge wird geprüft. |
| Farbe | Muss aktiv gewählt werden. `primary` ist nur die Darstellung des ungewählten Zustands, kein gültiger Wert – beim Submit wird der Farb-Button rot markiert. |
| Tier | Kann nicht fehlen, weil beim Öffnen zufällig vorbelegt. |
| Foto | Nur im Modus `photo` relevant: dann muss ein Foto vorhanden *und* der Upload fertig sein. Läuft er noch, wartet der Submit darauf, statt einen Fehler zu zeigen. |
| Verfügbarkeit | Läuft live und debounced neben der lokalen Prüfung; ein laufender Check sperrt den Button nicht, der 409 beim Submit ist das Sicherheitsnetz. |
| Button | Bleibt immer klickbar (kein ausgegrauter Button ohne Erklärung) – Feedback kommt über die Markierungen. |

**Qualitätseinstellungen (der eigentliche Punkt gegen "schlechte Fotos"):**
`pickImage` ohne `maxWidth`, `maxHeight` und `imageQuality` aufrufen – jede dieser Optionen lässt
`image_picker` das Bild vorab neu encodieren. Erst der Cropper erzeugt das Endbild: 1:1 erzwungen,
`maxWidth`/`maxHeight` 1024, `compressFormat: jpg`, `compressQuality: 90` (ergibt grob
150–250 KB). Nebeneffekt: Der Cropper encodiert immer neu, damit ist auch HEIC von iOS-Kameras
erledigt – `image_picker` allein konvertiert HEIC auf Android *nicht*.

- [ ] Bild-Auswahl und -Zuschnitt hinter ein schmales Interface legen (`ImagePickerService` oder
      ähnlich), damit das ViewModel ohne Plattform-Kanäle testbar bleibt

## 10. `shared/widgets/` – die app-weiten Bausteine

Maßstab für "gehört nach `shared/`": Das Widget lässt sich beschreiben, ohne das Wort *Profil*,
*Avatar-Modus* oder *Tier* zu benutzen. Jeder Punkt ist ein eigener Umsetzungsschritt, in dieser
Reihenfolge (von unten nach oben, damit nichts auf Ungebautes wartet).

**atoms/**

- [ ] `app_icon_button.dart` – runder Icon-Button in zwei Größen (`small` für das
      Bearbeiten-Symbol, `medium` für die Topbar), Vorder-/Hintergrundfarbe überschreibbar.
      Wird zum Standard für *alle* Icon-Buttons der App.
- [ ] `app_filled_button.dart` (vorhanden) erweitern: `backgroundColor`/`foregroundColor`
      überschreibbar und Eckenradius aus `AppRadius`, damit der Anlegen-Button im Design
      abgebildet werden kann. Bestehende Aufrufer bleiben unverändert (Defaults wie bisher).
- [ ] `avatar_view.dart` – zeigt entweder ein Foto oder ein Bild vor einer Hintergrundfarbe, in
      mehreren Größen. Nimmt primitive Parameter (`ImageProvider?`, `String? assetPath`, `Color`),
      dazu ein Convenience-Konstruktor für einen `Avatar` aus `core/user/`. Läuft später überall,
      wo ein Nutzer auftaucht.

**molecules/**

- [ ] `app_labeled_field.dart` – die dunkle Karte aus dem Design: kleines Label oben links, großer
      Eingabetext, Zeichen-Zähler oben rechts, optionaler Fehlerzustand (roter Rahmen + Meldung).
      Zähler zeigt `maxLength` an, schneidet die Eingabe aber nicht hart ab.
- [ ] `app_segmented_toggle.dart` – Umschalter mit zwei oder mehr Beschriftungen
      (`labels`, `selectedIndex`, `onChanged`); weiß nichts von Tier oder Foto.
- [ ] `app_editable_preview.dart` – nimmt ein beliebiges `child` und legt unten rechts einen
      `AppIconButton` mit Stift darüber; `onEdit`-Callback, optionaler Fehler-Rahmen. Wird auf
      diesem Screen dreimal benutzt (Tier, Farbe, Foto).
- [ ] `app_color_slider.dart` – ein Verlaufsbalken mit Knopf, der einen Wert von 0 bis 1 liefert.
      Zweimal benutzt: einmal mit Regenbogen-Verlauf (Farbton), einmal mit
      Dunkel-nach-Hell-Verlauf (Helligkeit). Kennt selbst kein HSV, das rechnet das Sheet.

**organisms/**

- [ ] `app_top_bar.dart` – der app-weite Kopf: optionales `leading` (ein `AppIconButton`), Titel
      mittig, bis zu drei `actions` rechts. Bringt seine eigene `SafeArea` mit, damit sie auch über
      einer randlosen, farbigen Fläche funktioniert. Farben werden nicht fest verdrahtet, sondern
      übergeben – auf diesem Screen liegt sie auf der Nutzerfarbe.
- [ ] `app_bottom_sheet.dart` – gemeinsames Gerüst für alle Sheets: Griff, Titel, scrollbarer
      Inhalt, `isScrollControlled`, plus eine `show`-Hilfsfunktion, damit die Aufrufer nicht jedes
      Mal `showModalBottomSheet` konfigurieren.
- [ ] `app_page_scaffold.dart` (vorhanden) auf `AppTopBar` umstellen statt auf eine Material-
      `AppBar`, und `leading`/`actions` durchreichen. Damit haben *alle* bestehenden Seiten
      denselben Kopf. Bestehende Aufrufer (Auth, Consent, Home, Nutzerprofil) übergeben weiterhin
      nur `title` – ein reines Innenleben-Refactoring.

## 11. Feature-Widgets, Section und Page

Alles hier ist feature-intern, weil es ohne die Begriffe Profil/Avatar/Tier nicht zu erklären ist.

```
ProfileSetupPage (pages/)                     – Scaffold + Section, sonst nichts
└── ProfileSetupSection                       – liest das ViewModel, verteilt Callbacks
    ├── ProfileAvatarHeader                   – farbige Fläche = gewählte Nutzerfarbe
    │   ├── AppTopBar               (shared)  – leading: null im Onboarding
    │   ├── AppSegmentedToggle      (shared)  – Tier | Foto
    │   ├── AppEditablePreview      (shared)  – großes Avatar-Bild
    │   │   └── AvatarView          (shared)
    │   ├── AppEditablePreview      (shared)  – runder Farbkreis
    │   └── AppEditablePreview      (shared)  – Foto-Kachel, zeigt Upload-Fortschritt
    └── ProfileFormFields                     – dunkler Block
        ├── AppLabeledField         (shared)  – Username, 20 Zeichen
        ├── AppLabeledField         (shared)  – Bio 1, 40 Zeichen
        ├── AppLabeledField         (shared)  – Bio 2, 80 Zeichen, mehrzeilig
        └── AppFilledButton         (shared)  – "Spieler anlegen"
```

- [ ] `presentation/widgets/profile_avatar_header.dart` – Kontrast: Text- und Icon-Farbe über
      `ThemeData.estimateBrightnessForColor` aus der gewählten Farbe ableiten, sonst wird bei
      hellen Nutzerfarben weiße Schrift unlesbar
- [ ] `presentation/widgets/profile_form_fields.dart`
- [ ] `presentation/widgets/animal_picker_sheet.dart` – Grid über alle 52 Tiere, scrollbar
      (`DraggableScrollableSheet`), aktuelle Auswahl markiert. Dabei `cacheWidth` passend zur
      Kachelgröße setzen: Die Bilder sind 768², ein dekodiertes belegt 2,4 MB RAM – ohne das
      liegen beim Scrollen schnell alle 52 in voller Auflösung im Speicher.
- [ ] `presentation/widgets/color_picker_sheet.dart` – Presets zur Schnellauswahl, darunter
      Farbton- und Helligkeits-Balken (zwei `AppColorSlider`), live-Vorschau des Avatars
- [ ] `presentation/widgets/photo_source_sheet.dart` – Kamera, Galerie, Foto entfernen
- [ ] `profile_setup_section.dart` neu aufbauen: bleibt **eine** Section (ein Formular, ein
      Submit), intern aus den Widgets oben zusammengesetzt
- [ ] `pages/profile_setup_page.dart`: hier **kein** `AppPageScaffold` – das Design ist randlos und
      der Kopf gehört zum farbigen Bereich der Section. Ein schlichtes `Scaffold` genügt.
- [ ] Tastatur: der untere Block muss über der Tastatur scrollbar sein
      (`resizeToAvoidBottomInset` + scrollbarer Inhalt), sonst ist Bio 2 auf kleinen Geräten
      nicht erreichbar

## 12. Lokalisierung

- [ ] `app_de.arb` und `app_en.arb`: Titel, Feld-Labels, Umschalter, Sheet-Titel, Buttons,
      Fehlermeldungen (Username fehlt / zu lang / falsches Format / bereits vergeben, Bio zu lang,
      Tier fehlt, Upload fehlgeschlagen)
- [ ] Entscheiden, ob die Tiernamen übersetzt angezeigt werden (52 × 2 Einträge) oder ob im Sheet
      nur die Bilder ohne Namen stehen – Letzteres spart viel Pflegeaufwand

## 13. Tests

- [ ] `domain/username_test.dart` erweitern: Länge nach oben, gültige und ungültige Formate
      (führender Punkt, doppelter Unterstrich, Umlaute)
- [ ] `domain/bio_line_test.dart`
- [ ] `domain/profile_draft_test.dart`: `validate()` meldet mehrere Fehler gleichzeitig; was im
      Tier- gegenüber dem Foto-Modus gespeichert wird
- [ ] `core/user/avatar_test.dart`: der Modus entscheidet über die Anzeige, Modus `photo` ohne
      `avatarUrl` fällt aufs Tier zurück
- [ ] `core/user/animal_asset_test.dart`: `fromName` liefert `null` statt zu werfen, jeder
      Enum-Wert hat eine passende Asset-Datei (fängt Tippfehler und vergessene Bilder ab)
- [ ] `core/user/user_repository_impl_test.dart` erweitern: 409 wird zu `ConflictException`
- [ ] `data/avatar_upload_service_test.dart`: der signierte `Content-Type` wird durchgereicht und
      im PUT steht **kein** `Authorization`-Header (der wichtigste Test in dieser Liste), dazu die
      Fehlerabbildung
- [ ] `presentation/profile_form_viewmodel_test.dart`: Validierung erst nach dem ersten Submit,
      danach live; Debounce und Abbruch der Verfügbarkeitsprüfung; Foto-Upload-Status; 409 landet
      am Username-Feld
- [ ] `presentation/profile_setup_section_test.dart` an das neue Formular anpassen
- [ ] `shared/widgets/app_labeled_field_test.dart` und `app_top_bar_test.dart` – die beiden
      Bausteine mit eigener Logik (Zähler/Fehlerzustand, `leading`/`actions` optional)
- [ ] Golden Tests weiterhin bewusst nicht (Begründung in `architecture-cleanup.md`, Punkt I)

## 14. Abschluss

- [ ] `fvm flutter analyze`, `fvm dart run import_lint`, `fvm flutter test`
- [ ] `docs/architecture/feature-status.md` aktualisieren (`features/user_profile`, `core/user`,
      neue `shared`-Bausteine)
- [ ] Manuell auf einem echten Android-Gerät gegen das Render-Backend durchspielen: Foto aus der
      Galerie, Foto per Kamera, Tier und Farbe, vergebener Username, Flugmodus während des Uploads
- [ ] Das Ergebnisbild einmal in R2 kontrollieren (Dateigröße und Schärfe) – das ist die Abnahme
      für das Qualitätsziel aus Abschnitt 9

## Offene Punkte

- Bekommt der Kopfbereich später noch Inhalt (das Design zeigt viel freie Fläche) oder ist die
  Höhe fix?
- Die Reihenfolge im Sheet: sollen die 52 Tiere alphabetisch stehen, gruppiert (Wald, Wasser, ...)
  oder in einer festen kuratierten Reihenfolge? Bei 52 Einträgen ist Scrollen ohne Ordnung mühsam.
- Braucht die Topbar außer dem X später wirklich bis zu drei Aktions-Buttons, oder reicht einer?
