enum KniffelTotal {
  upperSum, difference, bonus, upperTotal,
  lowerTotal, extraKniffel,
  grandTotal;

  bool get isEmphasized =>
      this == upperTotal || this == lowerTotal || this == grandTotal;
  
  bool get followedByDivider =>
      this == upperTotal || this == lowerTotal || this == extraKniffel;
}