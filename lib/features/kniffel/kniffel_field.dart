enum KniffelField {
  ones, twos, threes, fours, fives, sixes,
  threeOfAKind, fourOfAKind, fullHouse,
  smallStraight, largeStraight, kniffel, chance;

  bool get isUpper => index <= sixes.index;

  int? get faceValue => isUpper ? index + 1 : null;

  List<int>? get selectorValues =>
      isUpper ? List.generate(6, (n) => n * faceValue!) : null;

  int? get fixedScore => switch (this) {
        fullHouse => 25,
        smallStraight => 30,
        largeStraight => 40,
        kniffel => 50,
        _ => null,
      };

  bool get isManualInput =>
      this == threeOfAKind || this == fourOfAKind || this == chance;

  bool get canCross => this != chance;

  ChipKind get chipKind {
    if (isUpper) return ChipKind.selector;
    if (isManualInput) return ChipKind.manualInput;
    return ChipKind.fixedValue;
  }

  bool isValidManualValue(int value) => switch (this) {
    threeOfAKind || fourOfAKind || chance => value >= 5 && value <= 30,
    _ => false, // kein manuelles Feld
  };
}



  enum ChipKind { selector, manualInput, fixedValue }