import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'l10n/app_localizations.dart';
import 'instrument_surface.dart';
import 'performance_controls.dart';
import 'saved_beat.dart';
import 'soundboard.dart';

enum _SavedBeatFilter { name, date, duration }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.locale,
    required this.onLocaleChanged,
    super.key,
  });

  final Locale locale;
  final Future<void> Function(Locale locale) onLocaleChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final Soundboard _sb = Soundboard();
  SavedBeatStore? _beatStore;
  List<SavedBeat> _savedBeats = [];
  String? _activeSavedBeatId;
  _SavedBeatFilter _savedBeatFilter = _SavedBeatFilter.name;
  bool _hasUnsavedRecording = false;
  bool _loading = true;
  bool _audioFailed = false;

  // 0 = Drum, 1 = Cymbals, 2 = Gong
  int _mode = 0;
  bool _showAbout = false;

  late Ticker _ticker;
  Duration _lastTick = Duration.zero;
  Duration _lastStatusTick = Duration.zero;
  final ValueNotifier<int> _strikes = ValueNotifier(0);

  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  static const _red = Color(0xFFCC0000);
  static const _gold = Color(0xFFD7B675);

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    // Let the loading screen draw before starting native audio and ad work.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_init());
      unawaited(_initializeAds());
    });
  }

  Future<void> _init() async {
    try {
      await _sb.init();
    } catch (error, stack) {
      debugPrint('Audio initialization failed: $error\n$stack');
      if (mounted) {
        setState(() {
          _loading = false;
          _audioFailed = true;
        });
      }
      return;
    }
    if (!mounted) return;
    try {
      _beatStore = await SavedBeatStore.create();
      _savedBeats = await _beatStore!.loadAll();
    } catch (_) {
      if (mounted) {
        _showSnack(_l10n.savedBeatsLoadError);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _initializeAds() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    try {
      await MobileAds.instance.initialize();
      if (mounted) _loadAd();
    } catch (error, stack) {
      debugPrint('Ad initialization failed: $error\n$stack');
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: defaultTargetPlatform == TargetPlatform.android
          ? 'ca-app-pub-7760662598407173/2927518920'
          : 'ca-app-pub-3940256099942544/2934735716',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _bannerLoaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final ended =
        _sb.replaying &&
        _sb.update(dt, onBeat: (type) => _flashStrike(type == 0));
    if (ended) {
      _ticker.stop();
      _lastTick = Duration.zero;
      setState(() {});
    } else if (elapsed - _lastStatusTick >= const Duration(milliseconds: 100)) {
      _lastStatusTick = elapsed;
      setState(() {});
    }
  }

  void _flashStrike(bool primary) {
    final next = _strikes.value.abs() + 1;
    _strikes.value = primary ? next : -next;
  }

  Future<void> _showInstrumentPicker() async {
    if (_sb.recording || _sb.replaying) return;
    final names = [_l10n.drum, _l10n.cymbals, _l10n.gong];
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: const Color(0xFF30171E),
        title: Text(_l10n.instrument, style: const TextStyle(color: _gold)),
        children: [
          for (var mode = 0; mode < names.length; mode++)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(mode),
              child: Row(
                children: [
                  Icon(
                    _mode == mode ? Icons.check : Icons.music_note_outlined,
                    color: _gold,
                  ),
                  const SizedBox(width: 12),
                  Text(names[mode]),
                ],
              ),
            ),
        ],
      ),
    );
    if (!mounted || selected == null || selected == _mode) return;
    _sb.stopCymbal();
    _sb.stopGong();
    setState(() => _mode = selected);
  }

  String _drumSoundName(DrumSound sound) => switch (sound) {
    DrumSound.original => _l10n.drumOriginal,
    DrumSound.deep => _l10n.drumDeep,
    DrumSound.warm => _l10n.drumWarm,
    DrumSound.tight => _l10n.drumTight,
  };

  Future<void> _showDrumPicker() async {
    if (_sb.recording || _sb.replaying) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          backgroundColor: const Color(0xFF1A0000),
          title: Text(_l10n.drumSound, style: const TextStyle(color: _gold)),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_l10n.drumSoundHint),
                  const SizedBox(height: 12),
                  for (final sound in DrumSound.values)
                    ListTile(
                      title: Text(_drumSoundName(sound)),
                      selected: _sb.drumSound == sound,
                      selectedColor: _gold,
                      leading: const Icon(Icons.volume_up_outlined),
                      trailing: _sb.drumSound == sound
                          ? const Icon(Icons.check, color: _gold)
                          : null,
                      onTap: () {
                        setState(() => _sb.drumSound = sound);
                        dialogSetState(() {});
                        _sb.tapDrum();
                      },
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_l10n.close),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleRecord() {
    setState(() {
      if (_sb.recording) {
        _sb.stopRecording();
        _ticker.stop();
        _lastTick = Duration.zero;
        _hasUnsavedRecording = _sb.hasRecording;
      } else {
        _activeSavedBeatId = null;
        _hasUnsavedRecording = false;
        _sb.startRecording();
        _lastTick = Duration.zero;
        _lastStatusTick = Duration.zero;
        _ticker.start();
      }
    });
  }

  void _toggleReplay() {
    setState(() {
      if (_sb.replaying) {
        _sb.stopReplay();
        _ticker.stop();
        _lastTick = Duration.zero;
      } else {
        _sb.startReplay();
        _lastTick = Duration.zero;
        _lastStatusTick = Duration.zero;
        _ticker.start();
      }
    });
  }

  void _onPrimaryTap() {
    switch (_mode) {
      case 0:
        final stopped = _sb.tapDrum();
        if (stopped) {
          _ticker.stop();
          _lastTick = Duration.zero;
        }
        if (stopped) _hasUnsavedRecording = _sb.hasRecording;
        if (stopped || _sb.recording) setState(() {});
        break;
      case 1:
        _sb.tapCymbal();
        break;
      default:
        _sb.tapGong();
    }
    _flashStrike(true);
  }

  void _onSecondaryTap() {
    switch (_mode) {
      case 0:
        final stopped = _sb.tapSide();
        if (stopped) {
          _ticker.stop();
          _lastTick = Duration.zero;
        }
        if (stopped) _hasUnsavedRecording = _sb.hasRecording;
        if (stopped || _sb.recording) setState(() {});
        break;
      case 1:
        _sb.stopCymbal();
        break;
      default:
        _sb.stopGong();
    }
    _flashStrike(false);
  }

  Color _instrumentColor() {
    switch (_mode) {
      case 0:
        return const Color(0xFF8B5E3C);
      case 1:
        return const Color(0xFF886600);
      default:
        return const Color(0xFF4A2800);
    }
  }

  Future<void> _showLanguageDialog() async {
    final l10n = _l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A0000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _gold, width: 2),
          ),
          title: Text(l10n.language, style: const TextStyle(color: _gold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption(
                dialogContext,
                const Locale('en'),
                '🇺🇸 ${l10n.languageEnglish}',
                l10n.languageEnglish,
              ),
              const SizedBox(height: 8),
              _languageOption(
                dialogContext,
                const Locale('zh'),
                '🇨🇳 ${l10n.languageChinese}',
                l10n.languageChinese,
              ),
              const SizedBox(height: 8),
              _languageOption(
                dialogContext,
                const Locale('vi'),
                '🇻🇳 ${l10n.languageVietnamese}',
                l10n.languageVietnamese,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.close, style: const TextStyle(color: _gold)),
            ),
          ],
        );
      },
    );
  }

  Widget _languageOption(
    BuildContext dialogContext,
    Locale locale,
    String label,
    String languageName,
  ) {
    final selected = widget.locale.languageCode == locale.languageCode;
    return SizedBox(
      width: double.infinity,
      child: _dialogButton(
        label,
        selected
            ? null
            : () => _selectLanguage(dialogContext, locale, languageName),
      ),
    );
  }

  Future<void> _selectLanguage(
    BuildContext dialogContext,
    Locale locale,
    String languageName,
  ) async {
    Navigator.of(dialogContext).pop();
    await widget.onLocaleChanged(locale);
    if (mounted) {
      _showSnack(_l10n.languageSaved(languageName));
    }
  }

  Future<void> _showMainMenu() async {
    final l10n = _l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A0000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _gold, width: 2),
          ),
          title: Text(l10n.menu, style: const TextStyle(color: _gold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: _dialogButton(l10n.about, () {
                  Navigator.of(dialogContext).pop();
                  setState(() => _showAbout = true);
                }),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: _dialogButton(
                  l10n.language,
                  () => _closeDialogThen(dialogContext, _showLanguageDialog),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.close, style: const TextStyle(color: _gold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBeatsDialog() async {
    if (_sb.recording || _sb.replaying || _beatStore == null) return;
    final l10n = _l10n;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        final dialogWidth = min(size.width * 0.75, 420.0);
        final dialogHeight = min(size.height * 0.6, 320.0);

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            final sortedBeats = _sortedSavedBeats();

            return AlertDialog(
              backgroundColor: const Color(0xFF1A0000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: _gold, width: 2),
              ),
              title: Text(
                l10n.savedBeats,
                style: const TextStyle(color: _gold),
              ),
              content: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _dialogButton(
                              l10n.saveCurrent,
                              _sb.hasRecording
                                  ? () => _closeDialogThen(
                                      dialogContext,
                                      _saveCurrentBeat,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildSavedBeatFilter(dialogSetState),
                      const SizedBox(height: 10),
                      if (_savedBeats.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            l10n.noSavedBeats,
                            style: const TextStyle(color: Colors.white60),
                          ),
                        )
                      else
                        Column(
                          children: [
                            for (final beat in sortedBeats)
                              _buildSavedBeatRow(beat, dialogContext),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.close, style: const TextStyle(color: _gold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSavedBeatFilter(StateSetter dialogSetState) {
    final l10n = _l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _gold.withAlpha(120)),
      ),
      child: Row(
        children: [
          Text(
            l10n.filterBy,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<_SavedBeatFilter>(
              value: _savedBeatFilter,
              dropdownColor: const Color(0xFF1A0000),
              iconEnabledColor: _gold,
              style: const TextStyle(color: _gold, fontWeight: FontWeight.w600),
              items: [
                for (final filter in _SavedBeatFilter.values)
                  DropdownMenuItem(
                    value: filter,
                    child: Text(_savedBeatFilterLabel(filter)),
                  ),
              ],
              onChanged: (filter) {
                if (filter == null) return;
                setState(() => _savedBeatFilter = filter);
                dialogSetState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  String _savedBeatFilterLabel(_SavedBeatFilter filter) {
    final l10n = _l10n;
    switch (filter) {
      case _SavedBeatFilter.name:
        return l10n.filterName;
      case _SavedBeatFilter.date:
        return l10n.filterDate;
      case _SavedBeatFilter.duration:
        return l10n.filterDuration;
    }
  }

  List<SavedBeat> _sortedSavedBeats() {
    final beats = List<SavedBeat>.of(_savedBeats);
    switch (_savedBeatFilter) {
      case _SavedBeatFilter.name:
        beats.sort((a, b) {
          final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          if (byName != 0) return byName;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        return beats;
      case _SavedBeatFilter.date:
        beats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return beats;
      case _SavedBeatFilter.duration:
        beats.sort((a, b) {
          final byDuration = b.duration.compareTo(a.duration);
          if (byDuration != 0) return byDuration;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        return beats;
    }
  }

  void _closeDialogThen(
    BuildContext dialogContext,
    Future<void> Function() action,
  ) {
    Navigator.of(dialogContext).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await action();
      }
    });
  }

  Widget _buildSavedBeatRow(SavedBeat beat, BuildContext dialogContext) {
    final active = beat.id == _activeSavedBeatId;
    final l10n = _l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? _red.withAlpha(120) : Colors.black38,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? _gold : _gold.withAlpha(120)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.beatMetadata(
                    beat.beatCount,
                    _formatDuration(beat.duration),
                  ),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _smallDialogButton(
            l10n.load,
            () => _closeDialogThen(dialogContext, () => _loadBeat(beat)),
          ),
          const SizedBox(width: 6),
          _smallDialogButton(
            l10n.overwrite,
            _sb.hasRecording
                ? () => _closeDialogThen(
                    dialogContext,
                    () => _overwriteBeat(beat),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          _smallDialogButton(
            l10n.delete,
            () => _closeDialogThen(dialogContext, () => _deleteBeat(beat)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCurrentBeat() async {
    final store = _beatStore;
    if (store == null || !_sb.hasRecording) return;
    final l10n = _l10n;

    final name = await _promptForName();
    if (name == null) return;

    final existing = store.findByName(_savedBeats, name);
    if (existing != null) {
      final replace = await _confirm(
        l10n.replaceSavedBeatTitle,
        l10n.replaceSavedBeatMessage(existing.name),
      );
      if (!replace) return;

      final updated = await store.overwrite(
        id: existing.id,
        name: name,
        recording: _sb.exportRecording(),
      );
      await _reloadSavedBeats();
      setState(() {
        _activeSavedBeatId = updated.id;
        _hasUnsavedRecording = false;
      });
      _showSnack(l10n.savedOverBeat(updated.name));
      return;
    }

    final saved = await store.saveNew(
      name: name,
      recording: _sb.exportRecording(),
    );
    await _reloadSavedBeats();
    setState(() {
      _activeSavedBeatId = saved.id;
      _hasUnsavedRecording = false;
    });
    _showSnack(l10n.savedBeat(saved.name));
  }

  Future<void> _loadBeat(SavedBeat beat) async {
    final l10n = _l10n;
    if (_hasUnsavedRecording) {
      final discard = await _confirm(
        l10n.loadSavedBeatTitle,
        l10n.loadSavedBeatMessage(beat.name),
      );
      if (!discard) return;
    }

    setState(() {
      _sb.loadRecording(beat.recording);
      _activeSavedBeatId = beat.id;
      _hasUnsavedRecording = false;
    });
    _showSnack(l10n.loadedBeat(beat.name));
  }

  Future<void> _overwriteBeat(SavedBeat beat) async {
    final store = _beatStore;
    if (store == null || !_sb.hasRecording) return;
    final l10n = _l10n;

    final replace = await _confirm(
      l10n.overwriteBeatTitle,
      l10n.overwriteBeatMessage(beat.name),
    );
    if (!replace) return;

    final updated = await store.overwrite(
      id: beat.id,
      recording: _sb.exportRecording(),
    );
    await _reloadSavedBeats();
    setState(() {
      _activeSavedBeatId = updated.id;
      _hasUnsavedRecording = false;
    });
    _showSnack(l10n.savedOverBeat(updated.name));
  }

  Future<void> _deleteBeat(SavedBeat beat) async {
    final store = _beatStore;
    if (store == null) return;
    final l10n = _l10n;

    final delete = await _confirm(
      l10n.deleteBeatTitle,
      l10n.deleteBeatMessage(beat.name),
    );
    if (!delete) return;

    await store.delete(beat.id);
    await _reloadSavedBeats();
    setState(() {
      if (_activeSavedBeatId == beat.id) {
        _activeSavedBeatId = null;
        _hasUnsavedRecording = _sb.hasRecording;
      }
    });
    _showSnack(l10n.deletedBeat(beat.name));
  }

  Future<void> _reloadSavedBeats() async {
    final store = _beatStore;
    if (store == null) return;
    _savedBeats = await store.loadAll();
  }

  Future<String?> _promptForName() async {
    final controller = TextEditingController();
    final l10n = _l10n;
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A0000),
          title: Text(l10n.nameBeat, style: const TextStyle(color: _gold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.beatName,
              labelStyle: const TextStyle(color: Colors.white70),
            ),
            onSubmitted: (_) {
              final trimmed = controller.text.trim();
              if (trimmed.isNotEmpty) Navigator.of(context).pop(trimmed);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel, style: const TextStyle(color: _gold)),
            ),
            TextButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isNotEmpty) Navigator.of(context).pop(trimmed);
              },
              child: Text(l10n.save, style: const TextStyle(color: _gold)),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return name;
  }

  Future<bool> _confirm(String title, String message) async {
    final l10n = _l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A0000),
          title: Text(title, style: const TextStyle(color: _gold)),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel, style: const TextStyle(color: _gold)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.confirm, style: const TextStyle(color: _gold)),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Widget _dialogButton(String label, VoidCallback? onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: _gold,
        disabledForegroundColor: Colors.white38,
        side: BorderSide(color: onTap == null ? Colors.white24 : _gold),
      ),
      child: Text(label),
    );
  }

  Widget _smallDialogButton(String label, VoidCallback? onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: _gold,
        disabledForegroundColor: Colors.white38,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  String _formatDuration(double seconds) {
    final l10n = _l10n;
    final minutes = seconds ~/ 60;
    final remainingSeconds = (seconds % 60).toStringAsFixed(1).padLeft(4, '0');
    return minutes > 0
        ? l10n.minutesDuration(minutes, remainingSeconds)
        : l10n.secondsDuration(seconds.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _ticker.dispose();
    _strikes.dispose();
    unawaited(_disposeAudio());
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _disposeAudio() async {
    try {
      await _sb.dispose();
    } catch (error, stack) {
      debugPrint('Audio shutdown failed: $error\n$stack');
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_audioFailed) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_l10n.audioLoadError),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _audioFailed = false;
                    _loading = true;
                  });
                  unawaited(_init());
                },
                child: Text(_l10n.retry),
              ),
            ],
          ),
        ),
      );
    }
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFCC0000)),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 1.3,
                  colors: [Color(0xFF481C24), Color(0xFF200C12)],
                ),
              ),
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.045,
                  child: Image.asset(
                    'assets/images/final.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: _buildInstrumentArea()),
          _buildTopBar(),
          if (_showAbout) _buildAboutOverlay(),
        ],
      ),
    );
  }

  Widget _buildInstrumentArea() {
    return InstrumentSurface(
      color: _instrumentColor(),
      primaryLabel: [_l10n.drum, _l10n.cymbals, _l10n.gong][_mode],
      secondaryLabel: _mode == 0 ? _l10n.side : _l10n.mute,
      onPrimaryTap: _onPrimaryTap,
      onSecondaryTap: _onSecondaryTap,
      strikes: _strikes,
    );
  }

  String get _performanceStatus {
    final names = [_l10n.drum, _l10n.cymbals, _l10n.gong];
    if (_mode != 0) return names[_mode];
    if (_sb.recording) {
      return '${_l10n.recording} · ${_l10n.beatMetadata(_sb.currentBeatCount, _formatDuration(_sb.elapsedSeconds))}';
    }
    if (_sb.replaying) {
      return '${_l10n.playing} · ${_formatDuration(_sb.elapsedSeconds)} / ${_formatDuration(_sb.recordingDuration)}';
    }
    if (_hasUnsavedRecording) return _l10n.unsavedBeat;
    if (_activeSavedBeatId != null) {
      for (final beat in _savedBeats) {
        if (beat.id == _activeSavedBeatId) return beat.name;
      }
    }
    return _l10n.ready;
  }

  Widget _buildTopBar() {
    return PerformanceControls(
      mode: _mode,
      soundName: _drumSoundName(_sb.drumSound),
      recording: _sb.recording,
      replaying: _sb.replaying,
      hasRecording: _sb.hasRecording,
      canUseLibrary: _beatStore != null,
      status: _performanceStatus,
      onMenu: _showMainMenu,
      onInstrument: _showInstrumentPicker,
      onSound: _showDrumPicker,
      onRecord: _toggleRecord,
      onReplay: _toggleReplay,
      onSave: _saveCurrentBeat,
      onLibrary: _showBeatsDialog,
      banner: _bannerLoaded && _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : null,
    );
  }

  Widget _buildAboutOverlay() {
    final l10n = _l10n;
    return GestureDetector(
      onTap: () => setState(() => _showAbout = false),
      child: Container(
        color: Colors.black.withAlpha(200),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0000),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold, width: 2),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/LionIcon.png', height: 64),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'v1.1.1',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.aboutDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.copyright,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => setState(() => _showAbout = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: _gold),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.close,
                        style: const TextStyle(color: _gold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
