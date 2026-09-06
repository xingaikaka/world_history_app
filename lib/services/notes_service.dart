import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/countries_data.dart';
import '../models/country.dart';

enum NoteTargetKind { figure, event }

class NoteEntry {
  final String storageKey;
  final NoteTargetKind kind;
  final String countryId;
  final String periodId;
  final String targetTitle;
  final String text;

  const NoteEntry({
    required this.storageKey,
    required this.kind,
    required this.countryId,
    required this.periodId,
    required this.targetTitle,
    required this.text,
  });

  Country? get country => countryById(countryId);

  HistoryPeriod? get period {
    final c = country;
    if (c == null) return null;
    try {
      return c.periods.firstWhere((p) => p.id == periodId);
    } catch (_) {
      return null;
    }
  }
}

(NoteTargetKind, String, String, String)? _parseKey(String key) {
  final parts = key.split('|');
  if (parts.length < 4) return null;
  final kind = parts[0] == 'f'
      ? NoteTargetKind.figure
      : parts[0] == 'e'
          ? NoteTargetKind.event
          : null;
  if (kind == null) return null;
  return (kind, parts[1], parts[2], parts.sublist(3).join('|'));
}

class NotesService extends ChangeNotifier {
  NotesService._();

  static final NotesService instance = NotesService._();

  static const _prefsKey = 'user_notes_v1';

  final Map<String, String> _notes = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  static String figureKey(String countryId, String periodId, String figureName) =>
      'f|$countryId|$periodId|$figureName';

  static String eventKey(String countryId, String periodId, String eventTitle) =>
      'e|$countryId|$periodId|$eventTitle';

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _notes.clear();
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in map.entries) {
          _notes[entry.key] = entry.value as String;
        }
      } catch (_) {
        _notes.clear();
      }
    }
    _loaded = true;
    notifyListeners();
  }

  String? getNote(String key) => _notes[key];

  bool hasNote(String key) => _notes.containsKey(key) && _notes[key]!.trim().isNotEmpty;

  int get noteCount => _notes.values.where((n) => n.trim().isNotEmpty).length;

  List<NoteEntry> get allEntries {
    final entries = <NoteEntry>[];
    for (final entry in _notes.entries) {
      if (entry.value.trim().isEmpty) continue;
      final parsed = _parseKey(entry.key);
      if (parsed == null) continue;
      entries.add(NoteEntry(
        storageKey: entry.key,
        kind: parsed.$1,
        countryId: parsed.$2,
        periodId: parsed.$3,
        targetTitle: parsed.$4,
        text: entry.value,
      ));
    }
    return entries;
  }

  Future<void> saveNote(String key, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _notes.remove(key);
    } else {
      _notes[key] = trimmed;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> deleteNote(String key) async {
    _notes.remove(key);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_notes));
  }
}
