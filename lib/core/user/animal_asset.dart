import 'dart:math';

/// Tier-Avatare, die die App als Bild mitbringt.
///
/// Der Enum-Name ist zugleich der Wert, den das Backend in `animalAssetName`
/// speichert, und der Dateiname unter `assets/images/animals/`. Deshalb gibt es
/// hier bewusst keine Zuordnungstabelle: Sie koennte auseinanderlaufen, ein
/// Tippfehler dagegen faellt sofort beim Laden des Bildes auf. Die
/// Doc-Comments nennen den deutschen Namen der Vorlage.
enum AnimalAsset {
  /// Anglerfisch.
  anglerfish,

  /// Baer.
  bear,

  /// Biber.
  beaver,

  /// Biene.
  bee,

  /// Katze.
  cat,

  /// Kuh.
  cow,

  /// Hirsch.
  deer,

  /// Hund.
  dog,

  /// Delfin.
  dolphin,

  /// Esel.
  donkey,

  /// Drache.
  dragon,

  /// Adler.
  eagle,

  /// Elefant.
  elephant,

  /// Fuchs.
  fox,

  /// Frosch.
  frog,

  /// Giraffe.
  giraffe,

  /// Ziege.
  goat,

  /// Hase.
  hare,

  /// Nilpferd.
  hippo,

  /// Pferd.
  horse,

  /// Qualle.
  jellyfish,

  /// Lemur.
  lemur,

  /// Loewe.
  lion,

  /// Affe.
  monkey,

  /// Maus.
  mouse,

  /// Krake.
  octopus,

  /// Orca.
  orca,

  /// Otter.
  otter,

  /// Eule.
  owl,

  /// Panda.
  panda,

  /// Panther.
  panther,

  /// Papagei.
  parrot,

  /// Pinguin.
  penguin,

  /// Phoenix.
  phoenix,

  /// Schwein.
  pig,

  /// Rabe.
  raven,

  /// Nashorn.
  rhino,

  /// Hahn.
  rooster,

  /// Moewe.
  seagull,

  /// Seepferdchen.
  seahorse,

  /// Seehund.
  seal,

  /// Hai.
  shark,

  /// Faultier.
  sloth,

  /// Schnecke.
  snail,

  /// Schlange.
  snake,

  /// Spinne.
  spider,

  /// Eichhoernchen.
  squirrel,

  /// Tapir.
  tapir,

  /// Tiger.
  tiger,

  /// Schildkroete.
  turtle,

  /// Blauwal.
  whale,

  /// Wolf.
  wolf;

  /// Pfad des Bildes im Asset-Bundle.
  String get assetPath => 'assets/images/animals/$name.webp';

  /// Nachschlagewerk fuer [fromName], einmalig aufgebaut statt bei jedem
  /// Aufruf - Avatare werden in Listen sehr oft gerendert.
  static final Map<String, AnimalAsset> _byName = values.asNameMap();

  /// Der Eintrag zu [name], oder `null` wenn es ihn nicht gibt.
  ///
  /// Bewusst tolerant statt werfend: Das Backend kann ein Tier liefern, das
  /// erst eine neuere App-Version kennt. Der Aufrufer entscheidet dann, worauf
  /// er zurueckfaellt - abstuerzen soll die App deswegen nicht.
  static AnimalAsset? fromName(String? name) =>
      name == null ? null : _byName[name];

  /// Ein zufaelliges Tier, fuer die Vorbelegung beim Anlegen eines Profils.
  ///
  /// [generator] laesst sich in Tests durch eine feste Quelle ersetzen.
  static AnimalAsset random([Random? generator]) =>
      values[(generator ?? Random()).nextInt(values.length)];
}
