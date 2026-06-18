// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signIn => 'LOGIN';

  @override
  String get kniffelFieldOnes => 'Aces';

  @override
  String get kniffelFieldTwos => 'Twos';

  @override
  String get kniffelFieldThrees => 'Threes';

  @override
  String get kniffelFieldFours => 'Fours';

  @override
  String get kniffelFieldFives => 'Fives';

  @override
  String get kniffelFieldSixes => 'Sixes';

  @override
  String get kniffelFieldThreeOfAKind => 'Three of a kind';

  @override
  String get kniffelFieldFourOfAKind => 'Four of a kind';

  @override
  String get kniffelFieldFullHouse => 'Full House';

  @override
  String get kniffelFieldSmallStraight => 'Small Straight';

  @override
  String get kniffelFieldLargeStraight => 'Large Straight';

  @override
  String get kniffelFieldKniffel => 'Yahtzee';

  @override
  String get kniffelFieldChance => 'Chance';

  @override
  String get kniffelTotalUpperSum => 'Upper sum';

  @override
  String get kniffelTotalDifference => 'Difference';

  @override
  String get kniffelTotalBonus => 'Bonus';

  @override
  String get kniffelTotalUpperTotal => 'Upper total';

  @override
  String get kniffelTotalLowerTotal => 'Lower total';

  @override
  String get kniffelTotalExtraKniffel => 'Extra Kniffel';

  @override
  String get kniffelTotalGrandTotal => 'Total';

  @override
  String get kniffelSectionUpper => 'Upper block';

  @override
  String get kniffelSectionLower => 'Lower block';

  @override
  String get kniffelSectionTotals => 'Scores';
}
