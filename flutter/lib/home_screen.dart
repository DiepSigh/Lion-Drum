import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'soundboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final Soundboard _sb = Soundboard();
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

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _sb.init().then((_) => setState(() => _loading = false));
    _loadAd();
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
      } else {
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
        body: Center(child: CircularProgressIndicator(color: Color(0xFFCC0000))),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/final.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withAlpha(120)),
          ),
          Positioned.fill(
            child: _buildInstrumentArea(),
          ),
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
    final modeNames = ['Drum', 'Cymbals', 'Gong'];
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
                _topButton('About', () => setState(() => _showAbout = true)),
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
                    _sb.recording ? 'Recording' : 'Record',
                    _toggleRecord,
                    active: _sb.recording,
                    activeColor: _red,
                  ),
                if (_sb.hasRecording && !_sb.recording) ...[
                  if (isDrum && !_sb.replaying) const SizedBox(height: 8),
                  _topButton(
                    _sb.replaying ? 'Playing' : 'Play',
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
          color: active ? (activeColor ?? _dark) : (onTap != null ? _dark : Colors.black38),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? (activeColor ?? _gold) : _gold.withAlpha(180),
            width: active ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : (onTap != null ? _gold : Colors.white38),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutOverlay() {
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
                const Text(
                  'Lion Dance Kit',
                  style: TextStyle(
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
                const Text(
                  'A lion dance percussion simulator.\nDrum, side drum, cymbals and gong.\nRecord and replay your beats.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  '© DiepSigh',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _showAbout = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: _gold),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Close', style: TextStyle(color: _gold)),
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
