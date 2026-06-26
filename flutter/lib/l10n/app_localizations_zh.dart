// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '舞狮鼓乐';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get language => '语言';

  @override
  String languageSaved(Object language) {
    return '语言已设为$language。';
  }

  @override
  String get about => '关于';

  @override
  String get menu => '菜单';

  @override
  String get drum => '鼓';

  @override
  String get cymbals => '钹';

  @override
  String get gong => '锣';

  @override
  String get beats => '鼓点';

  @override
  String get record => '录制';

  @override
  String get recording => '录制中';

  @override
  String get play => '播放';

  @override
  String get playing => '播放中';

  @override
  String get savedBeats => '已保存鼓点';

  @override
  String get saveCurrent => '保存当前';

  @override
  String get filterBy => '筛选';

  @override
  String get filterName => '名称';

  @override
  String get filterDate => '日期';

  @override
  String get filterDuration => '时长';

  @override
  String get noSavedBeats => '没有已保存的鼓点';

  @override
  String get close => '关闭';

  @override
  String get load => '加载';

  @override
  String get overwrite => '覆盖';

  @override
  String get delete => '删除';

  @override
  String beatMetadata(int count, Object duration) {
    return '$count 个鼓点 - $duration';
  }

  @override
  String secondsDuration(Object seconds) {
    return '$seconds秒';
  }

  @override
  String minutesDuration(int minutes, Object seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get nameBeat => '命名鼓点';

  @override
  String get beatName => '鼓点名称';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get confirm => '确认';

  @override
  String get replaceSavedBeatTitle => '覆盖已保存鼓点？';

  @override
  String replaceSavedBeatMessage(Object name) {
    return '“$name”已存在。要覆盖它吗？';
  }

  @override
  String savedOverBeat(Object name) {
    return '已覆盖“$name”。';
  }

  @override
  String savedBeat(Object name) {
    return '已保存“$name”。';
  }

  @override
  String get loadSavedBeatTitle => '加载已保存鼓点？';

  @override
  String loadSavedBeatMessage(Object name) {
    return '当前录制尚未保存。仍要加载“$name”吗？';
  }

  @override
  String loadedBeat(Object name) {
    return '已加载“$name”。';
  }

  @override
  String get overwriteBeatTitle => '覆盖鼓点？';

  @override
  String overwriteBeatMessage(Object name) {
    return '用当前录制覆盖“$name”吗？';
  }

  @override
  String get deleteBeatTitle => '删除鼓点？';

  @override
  String deleteBeatMessage(Object name) {
    return '从已保存鼓点中删除“$name”吗？';
  }

  @override
  String deletedBeat(Object name) {
    return '已删除“$name”。';
  }

  @override
  String get savedBeatsLoadError => '无法加载已保存鼓点。';

  @override
  String get aboutDescription => '舞狮打击乐模拟器。\n鼓、边鼓、钹和锣。\n录制并回放你的鼓点。';

  @override
  String get copyright => '© DiepSigh';
}
