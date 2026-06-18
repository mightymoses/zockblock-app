import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get signIn;

  /// No description provided for @kniffelFieldOnes.
  ///
  /// In en, this message translates to:
  /// **'Aces'**
  String get kniffelFieldOnes;

  /// No description provided for @kniffelFieldTwos.
  ///
  /// In en, this message translates to:
  /// **'Twos'**
  String get kniffelFieldTwos;

  /// No description provided for @kniffelFieldThrees.
  ///
  /// In en, this message translates to:
  /// **'Threes'**
  String get kniffelFieldThrees;

  /// No description provided for @kniffelFieldFours.
  ///
  /// In en, this message translates to:
  /// **'Fours'**
  String get kniffelFieldFours;

  /// No description provided for @kniffelFieldFives.
  ///
  /// In en, this message translates to:
  /// **'Fives'**
  String get kniffelFieldFives;

  /// No description provided for @kniffelFieldSixes.
  ///
  /// In en, this message translates to:
  /// **'Sixes'**
  String get kniffelFieldSixes;

  /// No description provided for @kniffelFieldThreeOfAKind.
  ///
  /// In en, this message translates to:
  /// **'Three of a kind'**
  String get kniffelFieldThreeOfAKind;

  /// No description provided for @kniffelFieldFourOfAKind.
  ///
  /// In en, this message translates to:
  /// **'Four of a kind'**
  String get kniffelFieldFourOfAKind;

  /// No description provided for @kniffelFieldFullHouse.
  ///
  /// In en, this message translates to:
  /// **'Full House'**
  String get kniffelFieldFullHouse;

  /// No description provided for @kniffelFieldSmallStraight.
  ///
  /// In en, this message translates to:
  /// **'Small Straight'**
  String get kniffelFieldSmallStraight;

  /// No description provided for @kniffelFieldLargeStraight.
  ///
  /// In en, this message translates to:
  /// **'Large Straight'**
  String get kniffelFieldLargeStraight;

  /// No description provided for @kniffelFieldKniffel.
  ///
  /// In en, this message translates to:
  /// **'Yahtzee'**
  String get kniffelFieldKniffel;

  /// No description provided for @kniffelFieldChance.
  ///
  /// In en, this message translates to:
  /// **'Chance'**
  String get kniffelFieldChance;

  /// No description provided for @kniffelTotalUpperSum.
  ///
  /// In en, this message translates to:
  /// **'Upper sum'**
  String get kniffelTotalUpperSum;

  /// No description provided for @kniffelTotalDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get kniffelTotalDifference;

  /// No description provided for @kniffelTotalBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get kniffelTotalBonus;

  /// No description provided for @kniffelTotalUpperTotal.
  ///
  /// In en, this message translates to:
  /// **'Upper total'**
  String get kniffelTotalUpperTotal;

  /// No description provided for @kniffelTotalLowerTotal.
  ///
  /// In en, this message translates to:
  /// **'Lower total'**
  String get kniffelTotalLowerTotal;

  /// No description provided for @kniffelTotalExtraKniffel.
  ///
  /// In en, this message translates to:
  /// **'Extra Kniffel'**
  String get kniffelTotalExtraKniffel;

  /// No description provided for @kniffelTotalGrandTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get kniffelTotalGrandTotal;

  /// No description provided for @kniffelSectionUpper.
  ///
  /// In en, this message translates to:
  /// **'Upper block'**
  String get kniffelSectionUpper;

  /// No description provided for @kniffelSectionLower.
  ///
  /// In en, this message translates to:
  /// **'Lower block'**
  String get kniffelSectionLower;

  /// No description provided for @kniffelSectionTotals.
  ///
  /// In en, this message translates to:
  /// **'Scores'**
  String get kniffelSectionTotals;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
