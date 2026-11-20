import 'dart:typed_data';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'saved_beat.dart';

enum PlaybackState { idle, recording, replaying }

enum DrumSound {
  original('assets/sounds/drum.wav'),
  deep('assets/sounds/drum_deep.wav'),
  warm('assets/sounds/drum_warm.wav'),
  tight('assets/sounds/drum_tight.wav');

  const DrumSound(this.asset);

  final String asset;
}

class Soundboard {
  static const int maxBeats = SavedBeatLimits.maxBeats;

  final _soloud = SoLoud.instance;
  Future<void>? _initialization;
  Future<void>? _disposal;
  bool _disposed = false;
  final Map<DrumSound, AudioSource> _drumSources = {};
  DrumSound drumSound = DrumSound.original;
  AudioSource get _drumSource => _drumSources[drumSound]!;
  late AudioSource _sideSource;
  late AudioSource _cymbalSource;
  late AudioSource _gongSource;

  final List<SoundHandle> _cymbalHandles = [];
  final List<SoundHandle> _gongHandles = [];

  final Float64List _beatTimes = Float64List(maxBeats);
  final Int32List _beatTypes = Int32List(maxBeats);

  int _count = 0;
  int _lastCount = maxBeats;
  double _timestamp = 0.0;
  final Stopwatch _recordClock = Stopwatch();

  double get _recordTime => _recordClock.elapsedMicroseconds / 1e6;

  PlaybackState _state = PlaybackState.idle;
  bool hasRecording = false;

  bool get recording => _state == PlaybackState.recording;
  bool get replaying => _state == PlaybackState.replaying;
  int get beatCount => _lastCount;
  int get currentBeatCount =>
      recording ? _count : (hasRecording ? _lastCount : 0);
  double get elapsedSeconds => recording ? _recordTime : _timestamp;
  double get recordingDuration =>
      hasRecording && _lastCount > 0 ? _beatTimes[_lastCount - 1] : 0;

  Future<void> init() {
    if (_disposed) throw StateError('Soundboard has been disposed.');
    return _initialization = _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Live instruments must respond quickly alongside the recorded drums.
      // 256 frames is ~5.8 ms at 44.1 kHz; the default 2048 is ~46.4 ms.
      await _soloud.init(bufferSize: 256);
      if (_disposed) return;
      _drumSources.clear();
      for (final sound in DrumSound.values) {
        _drumSources[sound] = await _soloud.loadAsset(sound.asset);
        if (_disposed) return;
      }
      if (_disposed) return;
      _sideSource = await _soloud.loadAsset('assets/sounds/side.wav');
      if (_disposed) return;
      _cymbalSource = await _soloud.loadAsset('assets/sounds/cymbal.wav');
      if (_disposed) return;
      // Trimmed 10 ms of quiet lead-in; gong2.wav preserves the original audio.
      _gongSource = await _soloud.loadAsset('assets/sounds/gong_aligned.wav');
    } catch (_) {
      // Also clean up partial loads before a user retries initialization.
      await _soloud.deinitAsync();
      rethrow;
    }
  }

  /// Call each frame during replay with delta time in seconds.
  /// Returns true when replay finishes.
  bool update(double dt, {void Function(int type)? onBeat}) {
    _timestamp += dt;
    // Drain every beat whose time has passed this frame — prevents one-per-frame lag on fast rolls.
    while (_count < _lastCount && _timestamp >= _beatTimes[_count]) {
      if (_beatTypes[_count] == 0) {
        _soloud.play(_drumSource);
      } else {
        _soloud.play(_sideSource);
      }
      onBeat?.call(_beatTypes[_count]);
      if (_count + 1 == _lastCount) {
        stopReplay();
        return true;
      }
      _count++;
    }
    return false;
  }

  // Returns true if recording was auto-stopped (max beats reached)
  bool tapDrum() {
    _soloud.play(_drumSource);
    if (recording) {
      _beatTimes[_count] = _recordTime;
      _beatTypes[_count] = 0;
      _count++;
      hasRecording = true;
      if (_count >= maxBeats - 1) {
        stopRecording();
        return true;
      }
    }
    return false;
  }

  bool tapSide() {
    _soloud.play(_sideSource);
    if (recording) {
      _beatTimes[_count] = _recordTime;
      _beatTypes[_count] = 1;
      _count++;
      hasRecording = true;
      if (_count >= maxBeats - 1) {
        stopRecording();
        return true;
      }
    }
    return false;
  }

  void tapCymbal() {
    _cymbalHandles.add(_soloud.play(_cymbalSource));
  }

  void stopCymbal() {
    for (final h in _cymbalHandles) {
      _soloud.stop(h);
    }
    _cymbalHandles.clear();
  }

  void tapGong() {
    _gongHandles.add(_soloud.play(_gongSource));
  }

  void stopGong() {
    for (final h in _gongHandles) {
      _soloud.stop(h);
    }
    _gongHandles.clear();
  }

  void startRecording() {
    _count = 0;
    _lastCount = 0;
    hasRecording = false;
    _recordClock.reset();
    _recordClock.start();
    _state = PlaybackState.recording;
  }

  void stopRecording() {
    _recordClock.stop();
    _lastCount = _count;
    _state = PlaybackState.idle;
  }

  void startReplay() {
    _count = 0;
    _timestamp = 0.0;
    _state = PlaybackState.replaying;
  }

  void stopReplay() {
    _count = 0;
    _timestamp = 0.0;
    _state = PlaybackState.idle;
  }

  DrumBeatRecording exportRecording() {
    final times = List<double>.generate(_lastCount, (i) => _beatTimes[i]);
    final types = List<int>.generate(_lastCount, (i) => _beatTypes[i]);
    return DrumBeatRecording(beatTimes: times, beatTypes: types)..validate();
  }

  void loadRecording(DrumBeatRecording recording) {
    recording.validate();
    stopReplay();
    _recordClock.stop();

    _lastCount = recording.beatCount;
    _count = 0;
    _timestamp = 0.0;
    for (var i = 0; i < recording.beatCount; i++) {
      _beatTimes[i] = recording.beatTimes[i];
      _beatTypes[i] = recording.beatTypes[i];
    }
    hasRecording = recording.beatCount > 0;
    _state = PlaybackState.idle;
  }

  Future<void> dispose() {
    _disposed = true;
    _recordClock.stop();
    _state = PlaybackState.idle;
    return _disposal ??= _shutdown();
  }

  Future<void> _shutdown() async {
    try {
      // Native callbacks must stay alive until any in-flight loading finishes.
      await _initialization;
    } catch (_) {
      // Initialization already cleaned up its partially loaded resources.
    }
    // The engine owns all sources. Its asynchronous shutdown stops native
    // threads before closing callbacks, without blocking the main thread.
    await _soloud.deinitAsync();
    _cymbalHandles.clear();
    _gongHandles.clear();
  }
}
