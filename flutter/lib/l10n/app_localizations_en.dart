// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get startupLoading => 'Getting your instruments ready…';

  @override
  String get appTitle => 'Lion Dance Kit';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get language => 'Language';

  @override
  String languageSaved(Object language) {
    return 'Language set to $language.';
  }

  @override
  String get about => 'About';

  @override
  String get menu => 'Menu';

  @override
  String get visitYmtWebsite => 'Visit YMT Lion Dance';

  @override
  String get websiteOpenError =>
      'Could not open the website. Please try again.';

  @override
  String get instrument => 'Instrument';

  @override
  String get switchInstrument => 'Switch instrument';

  @override
  String get side => 'Side';

  @override
  String get mute => 'Mute';

  @override
  String get stop => 'Stop';

  @override
  String get stopRecording => 'Stop recording';

  @override
  String get stopPlayback => 'Stop playback';

  @override
  String get library => 'Library';

  @override
  String get ready => 'Ready';

  @override
  String get unsavedBeat => 'Unsaved beat';

  @override
  String get drum => 'Drum';

  @override
  String get drumSound => 'Sound';

  @override
  String get drumSoundHint => 'Tap a sound to select and preview it.';

  @override
  String get drumOriginal => 'Original';

  @override
  String get drumDeep => 'Deep';

  @override
  String get drumWarm => 'Warm';

  @override
  String get drumTight => 'Tight';

  @override
  String get cymbals => 'Cymbals';

  @override
  String get gong => 'Gong';

  @override
  String get beats => 'Beats';

  @override
  String get record => 'Record';

  @override
  String get recording => 'Recording';

  @override
  String get play => 'Play';

  @override
  String get playing => 'Playing';

  @override
  String get savedBeats => 'Saved Beats';

  @override
  String get saveCurrent => 'Save Current';

  @override
  String get filterBy => 'Filter by';

  @override
  String get filterName => 'Name';

  @override
  String get filterDate => 'Date';

  @override
  String get filterDuration => 'Duration';

  @override
  String get noSavedBeats => 'No saved beats';

  @override
  String get close => 'Close';

  @override
  String get load => 'Load';

  @override
  String get overwrite => 'Overwrite';

  @override
  String get delete => 'Delete';

  @override
  String beatMetadata(int count, Object duration) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count beats',
      one: '1 beat',
    );
    return '$_temp0 - $duration';
  }

  @override
  String secondsDuration(Object seconds) {
    return '${seconds}s';
  }

  @override
  String minutesDuration(int minutes, Object seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get nameBeat => 'Name Beat';

  @override
  String get beatName => 'Beat name';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get replaceSavedBeatTitle => 'Replace Saved Beat?';

  @override
  String replaceSavedBeatMessage(Object name) {
    return '\"$name\" already exists. Save over it?';
  }

  @override
  String savedOverBeat(Object name) {
    return 'Saved over \"$name\".';
  }

  @override
  String savedBeat(Object name) {
    return 'Saved \"$name\".';
  }

  @override
  String get loadSavedBeatTitle => 'Load Saved Beat?';

  @override
  String loadSavedBeatMessage(Object name) {
    return 'Your current recording has not been saved. Load \"$name\" anyway?';
  }

  @override
  String loadedBeat(Object name) {
    return 'Loaded \"$name\".';
  }

  @override
  String get overwriteBeatTitle => 'Overwrite Beat?';

  @override
  String overwriteBeatMessage(Object name) {
    return 'Save the current recording over \"$name\"?';
  }

  @override
  String get deleteBeatTitle => 'Delete Beat?';

  @override
  String deleteBeatMessage(Object name) {
    return 'Delete \"$name\" from saved beats?';
  }

  @override
  String deletedBeat(Object name) {
    return 'Deleted \"$name\".';
  }

  @override
  String get savedBeatsLoadError => 'Saved beats could not be loaded.';

  @override
  String get audioLoadError => 'Audio could not be started. Please try again.';

  @override
  String get retry => 'Try Again';

  @override
  String get aboutDescription =>
      'A lion dance percussion simulator.\nDrum, side drum, cymbals and gong.\nRecord and replay your beats.';

  @override
  String get copyright => '© DiepSigh';
}
