// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get startupLoading => 'Đang chuẩn bị nhạc cụ…';

  @override
  String get appTitle => 'Bộ Gõ Múa Lân';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String languageSaved(Object language) {
    return 'Đã chuyển sang $language.';
  }

  @override
  String get about => 'Giới thiệu';

  @override
  String get menu => 'Menu';

  @override
  String get visitYmtWebsite => 'Truy cập YMT Lion Dance';

  @override
  String get websiteOpenError => 'Không thể mở trang web. Vui lòng thử lại.';

  @override
  String get instrument => 'Nhạc cụ';

  @override
  String get switchInstrument => 'Đổi nhạc cụ';

  @override
  String get side => 'Thành trống';

  @override
  String get mute => 'Ngắt tiếng';

  @override
  String get stop => 'Dừng';

  @override
  String get stopRecording => 'Dừng thu';

  @override
  String get stopPlayback => 'Dừng phát';

  @override
  String get library => 'Thư viện';

  @override
  String get ready => 'Sẵn sàng';

  @override
  String get unsavedBeat => 'Nhịp chưa lưu';

  @override
  String get drum => 'Trống';

  @override
  String get drumSound => 'Âm trống';

  @override
  String get drumSoundHint => 'Chạm vào âm trống để chọn và nghe thử.';

  @override
  String get drumOriginal => 'Gốc';

  @override
  String get drumDeep => 'Trầm';

  @override
  String get drumWarm => 'Ấm';

  @override
  String get drumTight => 'Gọn';

  @override
  String get cymbals => 'Chập chõa';

  @override
  String get gong => 'Chiêng';

  @override
  String get beats => 'Nhịp';

  @override
  String get record => 'Thu';

  @override
  String get recording => 'Đang thu';

  @override
  String get play => 'Phát';

  @override
  String get playing => 'Đang phát';

  @override
  String get savedBeats => 'Nhịp đã lưu';

  @override
  String get saveCurrent => 'Lưu hiện tại';

  @override
  String get filterBy => 'Lọc theo';

  @override
  String get filterName => 'Tên';

  @override
  String get filterDate => 'Ngày';

  @override
  String get filterDuration => 'Thời lượng';

  @override
  String get noSavedBeats => 'Chưa có nhịp đã lưu';

  @override
  String get close => 'Đóng';

  @override
  String get load => 'Tải';

  @override
  String get overwrite => 'Ghi đè';

  @override
  String get delete => 'Xóa';

  @override
  String beatMetadata(int count, Object duration) {
    return '$count nhịp - $duration';
  }

  @override
  String secondsDuration(Object seconds) {
    return '$seconds giây';
  }

  @override
  String minutesDuration(int minutes, Object seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get nameBeat => 'Đặt tên nhịp';

  @override
  String get beatName => 'Tên nhịp';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get replaceSavedBeatTitle => 'Thay nhịp đã lưu?';

  @override
  String replaceSavedBeatMessage(Object name) {
    return '\"$name\" đã tồn tại. Lưu đè lên nhịp này?';
  }

  @override
  String savedOverBeat(Object name) {
    return 'Đã ghi đè \"$name\".';
  }

  @override
  String savedBeat(Object name) {
    return 'Đã lưu \"$name\".';
  }

  @override
  String get loadSavedBeatTitle => 'Tải nhịp đã lưu?';

  @override
  String loadSavedBeatMessage(Object name) {
    return 'Bản thu hiện tại chưa được lưu. Vẫn tải \"$name\"?';
  }

  @override
  String loadedBeat(Object name) {
    return 'Đã tải \"$name\".';
  }

  @override
  String get overwriteBeatTitle => 'Ghi đè nhịp?';

  @override
  String overwriteBeatMessage(Object name) {
    return 'Lưu bản thu hiện tại đè lên \"$name\"?';
  }

  @override
  String get deleteBeatTitle => 'Xóa nhịp?';

  @override
  String deleteBeatMessage(Object name) {
    return 'Xóa \"$name\" khỏi nhịp đã lưu?';
  }

  @override
  String deletedBeat(Object name) {
    return 'Đã xóa \"$name\".';
  }

  @override
  String get savedBeatsLoadError => 'Không thể tải nhịp đã lưu.';

  @override
  String get audioLoadError =>
      'Không thể khởi động âm thanh. Vui lòng thử lại.';

  @override
  String get retry => 'Thử lại';

  @override
  String get aboutDescription =>
      'Trình mô phỏng bộ gõ múa lân.\nTrống, trống phụ, chập chõa và chiêng.\nThu và phát lại nhịp của bạn.';

  @override
  String get copyright => '© DiepSigh';
}
