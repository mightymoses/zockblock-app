sealed class KniffelCell {
  const KniffelCell();

  bool get isEmpty => this is EmptyCell;

  int get score => switch (this) {
        EmptyCell() => 0,
        CrossedCell() => 0,
        ScoredCell(:final value) => value,
      };
}

class EmptyCell extends KniffelCell {
  const EmptyCell();
}

class ScoredCell extends KniffelCell {
  const ScoredCell(this.value);
  final int value;
}

class CrossedCell extends KniffelCell {
  const CrossedCell();
}