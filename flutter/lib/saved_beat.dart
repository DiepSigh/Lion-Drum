import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SavedBeatLimits {
  static const int maxBeats = 3000;
}

class SavedBeatValidationException implements Exception {
  SavedBeatValidationException(this.message);

  final String message;

  @override
  String toString() => 'SavedBeatValidationException: $message';
}

class DrumBeatRecording {
  const DrumBeatRecording({required this.beatTimes, required this.beatTypes});

  final List<double> beatTimes;
  final List<int> beatTypes;

  int get beatCount => beatTimes.length;

  double get duration => beatTimes.isEmpty ? 0.0 : beatTimes.last;

  Map<String, dynamic> toJson() => {
    'beatTimes': beatTimes,
    'beatTypes': beatTypes,
  };

  factory DrumBeatRecording.fromJson(Map<String, dynamic> json) {
    return DrumBeatRecording(
      beatTimes: _readDoubleList(json['beatTimes']),
      beatTypes: _readIntList(json['beatTypes']),
    )..validate();
  }

  void validate() {
    if (beatTimes.length != beatTypes.length) {
      throw SavedBeatValidationException('Beat times and types must match.');
    }
    if (beatTimes.length > SavedBeatLimits.maxBeats) {
      throw SavedBeatValidationException('Saved beat is too long.');
    }

    double previousTime = -1;
    for (var i = 0; i < beatTimes.length; i++) {
      final time = beatTimes[i];
      if (!time.isFinite || time < 0) {
        throw SavedBeatValidationException('Beat time must be non-negative.');
      }
      if (time < previousTime) {
        throw SavedBeatValidationException('Beat times must be ordered.');
      }
      previousTime = time;

      final type = beatTypes[i];
      if (type != 0 && type != 1) {
        throw SavedBeatValidationException('Beat type must be 0 or 1.');
      }
    }
  }
}

class SavedBeat {
  const SavedBeat({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.recording,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DrumBeatRecording recording;

  int get beatCount => recording.beatCount;

  double get duration => recording.duration;

  SavedBeat copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DrumBeatRecording? recording,
  }) {
    return SavedBeat(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recording: recording ?? this.recording,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'beatTimes': recording.beatTimes,
    'beatTypes': recording.beatTypes,
    'beatCount': beatCount,
    'duration': duration,
  };

  factory SavedBeat.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      throw SavedBeatValidationException('Saved beat name is required.');
    }

    final recording = DrumBeatRecording(
      beatTimes: _readDoubleList(json['beatTimes']),
      beatTypes: _readIntList(json['beatTypes']),
    )..validate();

    final id = (json['id'] as String?)?.trim();
    if (id == null || id.isEmpty) {
      throw SavedBeatValidationException('Saved beat id is required.');
    }

    return SavedBeat(
      id: id,
      name: name,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      recording: recording,
    );
  }
}

class SavedBeatStore {
  SavedBeatStore._(this._file);

  final File _file;

  static Future<SavedBeatStore> create() async {
    final directory = await getApplicationDocumentsDirectory();
    return SavedBeatStore._(File('${directory.path}/drum_beats_v1.json'));
  }

  static SavedBeatStore forFile(File file) => SavedBeatStore._(file);

  Future<List<SavedBeat>> loadAll() async {
    if (!await _file.exists()) {
      return [];
    }

    final contents = await _file.readAsString();
    if (contents.trim().isEmpty) {
      return [];
    }

    final decoded = jsonDecode(contents);
    if (decoded is! Map<String, dynamic>) {
      throw SavedBeatValidationException('Saved beat file is invalid.');
    }

    final beats = decoded['beats'];
    if (beats is! List) {
      return [];
    }

    return beats
        .whereType<Map<String, dynamic>>()
        .map(SavedBeat.fromJson)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<SavedBeat> saveNew({
    required String name,
    required DrumBeatRecording recording,
  }) async {
    final trimmedName = _validateName(name);
    recording.validate();

    final now = DateTime.now().toUtc();
    final beats = await loadAll();
    final beat = SavedBeat(
      id: _newId(now),
      name: trimmedName,
      createdAt: now,
      updatedAt: now,
      recording: recording,
    );

    beats
      ..removeWhere((saved) => _sameName(saved.name, trimmedName))
      ..add(beat);
    await _writeAll(beats);
    return beat;
  }

  Future<SavedBeat> overwrite({
    required String id,
    String? name,
    required DrumBeatRecording recording,
  }) async {
    recording.validate();
    final beats = await loadAll();
    final index = beats.indexWhere((beat) => beat.id == id);
    if (index == -1) {
      throw SavedBeatValidationException('Saved beat was not found.');
    }

    final existing = beats[index];
    final nextName = name == null ? existing.name : _validateName(name);
    final updated = existing.copyWith(
      name: nextName,
      updatedAt: DateTime.now().toUtc(),
      recording: recording,
    );

    beats[index] = updated;
    beats.removeWhere(
      (beat) => beat.id != id && _sameName(beat.name, nextName),
    );
    await _writeAll(beats);
    return updated;
  }

  Future<void> delete(String id) async {
    final beats = await loadAll();
    beats.removeWhere((beat) => beat.id == id);
    await _writeAll(beats);
  }

  SavedBeat? findByName(List<SavedBeat> beats, String name) {
    final trimmedName = name.trim();
    for (final beat in beats) {
      if (_sameName(beat.name, trimmedName)) {
        return beat;
      }
    }
    return null;
  }

  Future<void> _writeAll(List<SavedBeat> beats) async {
    await _file.parent.create(recursive: true);
    beats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final encoded = const JsonEncoder.withIndent('  ').convert({
      'version': 1,
      'beats': beats.map((beat) => beat.toJson()).toList(),
    });
    await _file.writeAsString(encoded);
  }

  static bool _sameName(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  static String _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw SavedBeatValidationException('Saved beat name is required.');
    }
    return trimmed;
  }

  static String _newId(DateTime now) =>
      '${now.microsecondsSinceEpoch.toRadixString(36)}'
      '-${DateTime.now().microsecond.toRadixString(36)}';
}

List<double> _readDoubleList(Object? value) {
  if (value is! List) {
    throw SavedBeatValidationException('Beat times must be a list.');
  }
  return value.map((item) {
    if (item is num) {
      return item.toDouble();
    }
    throw SavedBeatValidationException('Beat times must be numbers.');
  }).toList();
}

List<int> _readIntList(Object? value) {
  if (value is! List) {
    throw SavedBeatValidationException('Beat types must be a list.');
  }
  return value.map((item) {
    if (item is int) {
      return item;
    }
    throw SavedBeatValidationException('Beat types must be integers.');
  }).toList();
}
