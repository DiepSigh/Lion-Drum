import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lion Dance Kit'**
  String get appTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSaved.
  ///
  /// In en, this message translates to:
  /// **'Language set to {language}.'**
  String languageSaved(Object language);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @visitYmtWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit YMT Lion Dance'**
  String get visitYmtWebsite;

  /// No description provided for @websiteOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the website. Please try again.'**
  String get websiteOpenError;

  /// No description provided for @instrument.
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get instrument;

  /// No description provided for @switchInstrument.
  ///
  /// In en, this message translates to:
  /// **'Switch instrument'**
  String get switchInstrument;

  /// No description provided for @side.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get side;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecording;

  /// No description provided for @stopPlayback.
  ///
  /// In en, this message translates to:
  /// **'Stop playback'**
  String get stopPlayback;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @unsavedBeat.
  ///
  /// In en, this message translates to:
  /// **'Unsaved beat'**
  String get unsavedBeat;

  /// No description provided for @drum.
  ///
  /// In en, this message translates to:
  /// **'Drum'**
  String get drum;

  /// No description provided for @drumSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get drumSound;

  /// No description provided for @drumSoundHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a sound to select and preview it.'**
  String get drumSoundHint;

  /// No description provided for @drumOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get drumOriginal;

  /// No description provided for @drumDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep'**
  String get drumDeep;

  /// No description provided for @drumWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get drumWarm;

  /// No description provided for @drumTight.
  ///
  /// In en, this message translates to:
  /// **'Tight'**
  String get drumTight;

  /// No description provided for @cymbals.
  ///
  /// In en, this message translates to:
  /// **'Cymbals'**
  String get cymbals;

  /// No description provided for @gong.
  ///
  /// In en, this message translates to:
  /// **'Gong'**
  String get gong;

  /// No description provided for @beats.
  ///
  /// In en, this message translates to:
  /// **'Beats'**
  String get beats;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// No description provided for @savedBeats.
  ///
  /// In en, this message translates to:
  /// **'Saved Beats'**
  String get savedBeats;

  /// No description provided for @saveCurrent.
  ///
  /// In en, this message translates to:
  /// **'Save Current'**
  String get saveCurrent;

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterBy;

  /// No description provided for @filterName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get filterName;

  /// No description provided for @filterDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get filterDate;

  /// No description provided for @filterDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get filterDuration;

  /// No description provided for @noSavedBeats.
  ///
  /// In en, this message translates to:
  /// **'No saved beats'**
  String get noSavedBeats;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @load.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// No description provided for @overwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite'**
  String get overwrite;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @beatMetadata.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 beat} other{{count} beats}} - {duration}'**
  String beatMetadata(int count, Object duration);

  /// No description provided for @secondsDuration.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String secondsDuration(Object seconds);

  /// No description provided for @minutesDuration.
  ///
  /// In en, this message translates to:
  /// **'{minutes}:{seconds}'**
  String minutesDuration(int minutes, Object seconds);

  /// No description provided for @nameBeat.
  ///
  /// In en, this message translates to:
  /// **'Name Beat'**
  String get nameBeat;

  /// No description provided for @beatName.
  ///
  /// In en, this message translates to:
  /// **'Beat name'**
  String get beatName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @replaceSavedBeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace Saved Beat?'**
  String get replaceSavedBeatTitle;

  /// No description provided for @replaceSavedBeatMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" already exists. Save over it?'**
  String replaceSavedBeatMessage(Object name);

  /// No description provided for @savedOverBeat.
  ///
  /// In en, this message translates to:
  /// **'Saved over \"{name}\".'**
  String savedOverBeat(Object name);

  /// No description provided for @savedBeat.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{name}\".'**
  String savedBeat(Object name);

  /// No description provided for @loadSavedBeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Load Saved Beat?'**
  String get loadSavedBeatTitle;

  /// No description provided for @loadSavedBeatMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current recording has not been saved. Load \"{name}\" anyway?'**
  String loadSavedBeatMessage(Object name);

  /// No description provided for @loadedBeat.
  ///
  /// In en, this message translates to:
  /// **'Loaded \"{name}\".'**
  String loadedBeat(Object name);

  /// No description provided for @overwriteBeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite Beat?'**
  String get overwriteBeatTitle;

  /// No description provided for @overwriteBeatMessage.
  ///
  /// In en, this message translates to:
  /// **'Save the current recording over \"{name}\"?'**
  String overwriteBeatMessage(Object name);

  /// No description provided for @deleteBeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Beat?'**
  String get deleteBeatTitle;

  /// No description provided for @deleteBeatMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" from saved beats?'**
  String deleteBeatMessage(Object name);

  /// No description provided for @deletedBeat.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\".'**
  String deletedBeat(Object name);

  /// No description provided for @savedBeatsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Saved beats could not be loaded.'**
  String get savedBeatsLoadError;

  /// No description provided for @audioLoadError.
  ///
  /// In en, this message translates to:
  /// **'Audio could not be started. Please try again.'**
  String get audioLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A lion dance percussion simulator.\nDrum, side drum, cymbals and gong.\nRecord and replay your beats.'**
  String get aboutDescription;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© DiepSigh'**
  String get copyright;
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
      <String>['en', 'vi', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
