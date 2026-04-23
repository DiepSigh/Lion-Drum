import 'dart:typed_data';
import 'package:flutter_soloud/flutter_soloud.dart';

enum PlaybackState { idle, recording, replaying }

class Soundboard {
  static const int maxBeats = 3000;

  final _soloud = SoLoud.instance;
  late final AudioSource _drumSource;
  late final AudioSource _sideSource;
  late final AudioSource _cymbalSource;
  late final AudioSource _gongSource;

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

  Future<void> init() async {
    await _soloud.init();
    _drumSource = await _soloud.loadAsset('assets/sounds/drum.wav');
    _sideSource = await _soloud.loadAsset('assets/sounds/side.wav');
    _cymbalSource = await _soloud.loadAsset('assets/sounds/cymbal.wav');
    _gongSource = await _soloud.loadAsset('assets/sounds/gong2.wav');
  }

  /// Call each frame during replay with delta time in seconds.
  /// Returns true when replay finishes.
  bool update(double dt) {
    _timestamp += dt;
    // Drain every beat whose time has passed this frame — prevents one-per-frame lag on fast rolls.
    while (_count < _lastCount && _timestamp >= _beatTimes[_count]) {
      if (_beatTypes[_count] == 0) {
        _soloud.play(_drumSource);
      } else {
        _soloud.play(_sideSource);
      }
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

  void dispose() {
    _soloud.disposeSource(_drumSource);
    _soloud.disposeSource(_sideSource);
    _soloud.disposeSource(_cymbalSource);
    _soloud.disposeSource(_gongSource);
    _soloud.deinit();
  }
}
