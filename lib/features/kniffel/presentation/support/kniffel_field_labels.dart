import 'package:zockblock_app/l10n/app_localizations.dart';

import '../../domain/kniffel_field.dart';
import '../../domain/kniffel_total.dart';

extension KniffelFieldLabels on KniffelField {
  String label(AppLocalizations l10n) => switch (this) {
        KniffelField.ones => l10n.kniffelFieldOnes,
        KniffelField.twos => l10n.kniffelFieldTwos,
        KniffelField.threes => l10n.kniffelFieldThrees,
        KniffelField.fours => l10n.kniffelFieldFours,
        KniffelField.fives => l10n.kniffelFieldFives,
        KniffelField.sixes => l10n.kniffelFieldSixes,
        KniffelField.threeOfAKind => l10n.kniffelFieldThreeOfAKind,
        KniffelField.fourOfAKind => l10n.kniffelFieldFourOfAKind,
        KniffelField.fullHouse => l10n.kniffelFieldFullHouse,
        KniffelField.smallStraight => l10n.kniffelFieldSmallStraight,
        KniffelField.largeStraight => l10n.kniffelFieldLargeStraight,
        KniffelField.kniffel => l10n.kniffelFieldKniffel,
        KniffelField.chance => l10n.kniffelFieldChance,
      };
}

extension KniffelTotalLabels on KniffelTotal {
  String label(AppLocalizations l10n) => switch (this) {
        KniffelTotal.upperSum => l10n.kniffelTotalUpperSum,
        KniffelTotal.difference => l10n.kniffelTotalDifference,
        KniffelTotal.bonus => l10n.kniffelTotalBonus,
        KniffelTotal.upperTotal => l10n.kniffelTotalUpperTotal,
        KniffelTotal.lowerTotal => l10n.kniffelTotalLowerTotal,
        KniffelTotal.extraKniffel => l10n.kniffelTotalExtraKniffel,
        KniffelTotal.grandTotal => l10n.kniffelTotalGrandTotal,
      };
}