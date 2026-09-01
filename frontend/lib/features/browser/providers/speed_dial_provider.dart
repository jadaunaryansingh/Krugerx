import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../core/storage.dart';
import '../models/speed_dial_model.dart';

/// Default speed dial entries, seeded on first launch.
const _defaults = [
  ('Google', 'https://www.google.com', 'search'),
  ('YouTube', 'https://www.youtube.com', 'play_circle_outline'),
  ('GitHub', 'https://github.com', 'code'),
  ('Reddit', 'https://www.reddit.com', 'forum'),
  ('X / Twitter', 'https://x.com', 'tag'),
  ('Wikipedia', 'https://www.wikipedia.org', 'menu_book'),
  ('Stack Overflow', 'https://stackoverflow.com', 'layers'),
  ('LinkedIn', 'https://www.linkedin.com', 'work_outline'),
  ('ChatGPT', 'https://chat.openai.com', 'auto_awesome'),
  ('Gemini', 'https://gemini.google.com', 'star'),
];

class SpeedDialNotifier extends Notifier<List<SpeedDialEntry>> {
  @override
  List<SpeedDialEntry> build() {
    _init();
    return const [];
  }

  Future<void> _init() async {
    final existing = await Storage.db.speedDialEntrys.where().sortByPosition().findAll();
    if (existing.isNotEmpty) {
      state = existing;
      return;
    }
    // Seed defaults on first launch
    await Storage.db.writeTxn(() async {
      for (var i = 0; i < _defaults.length; i++) {
        final (name, url, icon) = _defaults[i];
        final entry = SpeedDialEntry()
          ..name = name
          ..url = url
          ..iconName = icon
          ..position = i;
        await Storage.db.speedDialEntrys.put(entry);
      }
    });
    state = await Storage.db.speedDialEntrys.where().sortByPosition().findAll();
  }

  Future<void> add(String name, String url) async {
    final entry = SpeedDialEntry()
      ..name = name
      ..url = url
      ..position = state.length;
    await Storage.db.writeTxn(() async {
      await Storage.db.speedDialEntrys.put(entry);
    });
    await _refresh();
  }

  Future<void> remove(int id) async {
    await Storage.db.writeTxn(() async {
      await Storage.db.speedDialEntrys.delete(id);
    });
    await _refresh();
  }

  Future<void> update(int id, String name, String url) async {
    await Storage.db.writeTxn(() async {
      final entry = await Storage.db.speedDialEntrys.get(id);
      if (entry != null) {
        entry.name = name;
        entry.url = url;
        await Storage.db.speedDialEntrys.put(entry);
      }
    });
    await _refresh();
  }

  Future<void> _refresh() async {
    state = await Storage.db.speedDialEntrys.where().sortByPosition().findAll();
  }
}

final speedDialProvider = NotifierProvider<SpeedDialNotifier, List<SpeedDialEntry>>(SpeedDialNotifier.new);
