import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'l10n/app_localizations.dart';
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

  // 0 = Drum, 1 = Cymbals, 2 = Gong
  int _mode = 0;
  bool _showAbout = false;

  late Ticker _ticker;
  Duration _lastTick = Duration.zero;

  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  static const _red = Color(0xFFCC0000);
  static const _gold = Color(0xFFFFD700);
  static const _dark = Color(0xCC000000);

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _init();
    _loadAd();
  }

  Future<void> _init() async {
    try {
      await _sb.init();
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

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-7760662598407173/2927518920'
          : 'ca-app-pub-3940256099942544/2934735716',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _bannerLoaded = true),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final ended = _sb.update(dt);
    if (ended) {
      _ticker.stop();
      _lastTick = Duration.zero;
      setState(() {});
    }
  }

  void _changeInstrument() {
    if (_sb.recording) return;
    setState(() => _mode = (_mode + 1) % 3);
  }

  void _toggleRecord() {
    setState(() {
      if (_sb.recording) {
        _sb.stopRecording();
        _hasUnsavedRecording = _sb.hasRecording;
      } else {
        _activeSavedBeatId = null;
        _hasUnsavedRecording = false;
        _sb.startRecording();
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
        _ticker.start();
      }
    });
  }

  void _onPrimaryTap() {
    switch (_mode) {
      case 0:
        final stopped = _sb.tapDrum();
        if (stopped) _hasUnsavedRecording = _sb.hasRecording;
        if (stopped || _sb.recording) setState(() {});
        break;
      case 1:
        _sb.tapCymbal();
        break;
      default:
        _sb.tapGong();
    }
  }

  void _onSecondaryTap() {
    switch (_mode) {
      case 0:
        final stopped = _sb.tapSide();
        if (stopped) _hasUnsavedRecording = _sb.hasRecording;
        if (stopped || _sb.recording) setState(() {});
        break;
      case 1:
        _sb.stopCymbal();
        break;
      default:
        _sb.stopGong();
    }
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
              SizedBox(
                width: double.infinity,
                child: _dialogButton(
                  l10n.savedBeats,
                  (_mode == 0 && !_sb.recording && !_sb.replaying)
                      ? () => _closeDialogThen(dialogContext, _showBeatsDialog)
                      : null,
                ),
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (final beat in sortedBeats)
                                _buildSavedBeatRow(beat, dialogContext),
                            ],
                          ),
                        ),
                      ),
                  ],
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
    _sb.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
            child: Image.asset('assets/images/final.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.black.withAlpha(120))),
          Positioned.fill(child: _buildInstrumentArea()),
          _buildTopBar(),
          if (_showAbout) _buildAboutOverlay(),
        ],
      ),
    );
  }

  Widget _buildInstrumentArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final outerSize = min(w * 0.95, h * 2.0) * 5 / 9;
        final outerR = outerSize / 2;
        final cx = w / 2;
        final cy = h;

        final color = _instrumentColor();

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            final dx = event.localPosition.dx - cx;
            final dy = event.localPosition.dy - cy;
            final dist = sqrt(dx * dx + dy * dy);
            if (dist <= outerR) {
              _onPrimaryTap();
            } else {
              _onSecondaryTap();
            }
          },
          child: Stack(
            children: [
              Positioned(
                left: cx - outerR,
                top: cy - outerR,
                width: outerSize,
                height: outerSize,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(color: _gold, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(160),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    final l10n = _l10n;
    final modeNames = [l10n.drum, l10n.cymbals, l10n.gong];
    final isDrum = _mode == 0;
    return Stack(
      children: [
        if (_bannerLoaded && _bannerAd != null)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 8, 8),
            child: Row(
              children: [
                _topButton(l10n.menu, _showMainMenu),
                const SizedBox(width: 8),
                _topButton(
                  modeNames[_mode],
                  _sb.recording ? null : _changeInstrument,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isDrum && !_sb.replaying)
                  _topButton(
                    _sb.recording ? l10n.recording : l10n.record,
                    _toggleRecord,
                    active: _sb.recording,
                    activeColor: _red,
                  ),
                if (_sb.hasRecording && !_sb.recording) ...[
                  if (isDrum && !_sb.replaying) const SizedBox(height: 8),
                  _topButton(
                    _sb.replaying ? l10n.playing : l10n.play,
                    _toggleReplay,
                    active: _sb.replaying,
                    activeColor: const Color(0xFF006600),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _topButton(
    String label,
    VoidCallback? onTap, {
    bool active = false,
    Color? activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? (activeColor ?? _dark)
              : (onTap != null ? _dark : Colors.black38),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? (activeColor ?? _gold) : _gold.withAlpha(180),
            width: active ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? Colors.white
                : (onTap != null ? _gold : Colors.white38),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/LionIcon.png', height: 64),
                const SizedBox(height: 12),
                Text(
                  'Lion Dance Kit',
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'v0.9',
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
    );
  }
}
