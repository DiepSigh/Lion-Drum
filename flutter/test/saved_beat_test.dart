import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lion_dance_kit/saved_beat.dart';

void main() {
  group('DrumBeatRecording', () {
    test('round trips through json', () {
      const recording = DrumBeatRecording(
        beatTimes: [0.1, 0.25, 1.0],
        beatTypes: [0, 1, 0],
      );

      final decoded = DrumBeatRecording.fromJson(recording.toJson());

      expect(decoded.beatTimes, recording.beatTimes);
      expect(decoded.beatTypes, recording.beatTypes);
      expect(decoded.beatCount, 3);
      expect(decoded.duration, 1.0);
    });

    test('rejects mismatched beat arrays', () {
      expect(
        () => const DrumBeatRecording(
          beatTimes: [0.1],
          beatTypes: [0, 1],
        ).validate(),
        throwsA(isA<SavedBeatValidationException>()),
      );
    });

    test('rejects invalid beat types', () {
      expect(
        () => const DrumBeatRecording(
          beatTimes: [0.1],
          beatTypes: [2],
        ).validate(),
        throwsA(isA<SavedBeatValidationException>()),
      );
    });

    test('rejects too many beats', () {
      expect(
        () => DrumBeatRecording(
          beatTimes: List<double>.filled(SavedBeatLimits.maxBeats + 1, 0.1),
          beatTypes: List<int>.filled(SavedBeatLimits.maxBeats + 1, 0),
        ).validate(),
        throwsA(isA<SavedBeatValidationException>()),
      );
    });
  });

  group('SavedBeatStore', () {
    late Directory tempDir;
    late SavedBeatStore store;

    const firstRecording = DrumBeatRecording(
      beatTimes: [0.1, 0.35],
      beatTypes: [0, 1],
    );
    const secondRecording = DrumBeatRecording(
      beatTimes: [0.2, 0.45, 0.7],
      beatTypes: [1, 0, 1],
    );

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('saved_beat_test_');
      store = SavedBeatStore.forFile(
        File('${tempDir.path}/drum_beats_v1.json'),
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('returns empty list when file is missing', () async {
      expect(await store.loadAll(), isEmpty);
    });

    test('saves and loads beats', () async {
      final saved = await store.saveNew(
        name: 'Practice',
        recording: firstRecording,
      );

      final beats = await store.loadAll();

      expect(beats, hasLength(1));
      expect(beats.single.id, saved.id);
      expect(beats.single.name, 'Practice');
      expect(beats.single.beatCount, 2);
      expect(beats.single.recording.beatTypes, [0, 1]);
    });

    test('replaces existing beat when saving duplicate name', () async {
      final first = await store.saveNew(
        name: 'Practice',
        recording: firstRecording,
      );

      final second = await store.saveNew(
        name: 'practice',
        recording: secondRecording,
      );

      final beats = await store.loadAll();

      expect(beats, hasLength(1));
      expect(beats.single.id, second.id);
      expect(beats.single.id, isNot(first.id));
      expect(beats.single.name, 'practice');
      expect(beats.single.beatCount, 3);
    });

    test('overwrites by id and keeps created date', () async {
      final saved = await store.saveNew(
        name: 'Opening',
        recording: firstRecording,
      );

      final updated = await store.overwrite(
        id: saved.id,
        name: 'Opening 2',
        recording: secondRecording,
      );

      final beats = await store.loadAll();

      expect(beats, hasLength(1));
      expect(updated.id, saved.id);
      expect(updated.createdAt, saved.createdAt);
      expect(beats.single.name, 'Opening 2');
      expect(beats.single.recording.beatTypes, [1, 0, 1]);
    });

    test('deletes beats', () async {
      final saved = await store.saveNew(
        name: 'Delete Me',
        recording: firstRecording,
      );

      await store.delete(saved.id);

      expect(await store.loadAll(), isEmpty);
    });

    test('rejects empty names', () async {
      expect(
        () => store.saveNew(name: '   ', recording: firstRecording),
        throwsA(isA<SavedBeatValidationException>()),
      );
    });
  });
}
