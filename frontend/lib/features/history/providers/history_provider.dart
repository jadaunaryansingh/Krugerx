import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../core/storage.dart';
import '../models/history_models.dart';

import 'dart:async';

class HistoryNotifier extends Notifier<List<LocalHistory>> {
  @override
  List<LocalHistory> build() {
    _watchData();
    return const [];
  }

  void _watchData() {
    _fetch();
    final sub = Storage.db.localHistorys.watchLazy().listen((_) => _fetch());
    ref.onDispose(() => sub.cancel());
  }

  Future<void> _fetch() async {
    final history = await Storage.db.localHistorys.where().sortByVisitTimeDesc().findAll();
    state = history;
  }

  Future<void> recordVisit(String url, {String? title}) async {
    if (url.isEmpty || url == 'about:blank') return;

    await Storage.db.writeTxn(() async {
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      final recent = await Storage.db.localHistorys
          .filter()
          .urlEqualTo(url)
          .visitTimeGreaterThan(twoHoursAgo)
          .sortByVisitTimeDesc()
          .findFirst();

      if (recent != null) {
        recent.visitCount += 1;
        recent.visitTime = DateTime.now();
        if (title != null && title.isNotEmpty) recent.title = title;
        recent.synced = false;
        await Storage.db.localHistorys.put(recent);
      } else {
        final entry = LocalHistory()
          ..url = url
          ..title = title
          ..visitTime = DateTime.now()
          ..visitCount = 1
          ..synced = false;
        await Storage.db.localHistorys.put(entry);
      }
    });
  }

  Future<void> updateTitle(String url, String title) async {
    if (url.isEmpty || title.isEmpty) return;
    await Storage.db.writeTxn(() async {
      final recent = await Storage.db.localHistorys
          .filter()
          .urlEqualTo(url)
          .sortByVisitTimeDesc()
          .findFirst();
      if (recent != null) {
        recent.title = title;
        await Storage.db.localHistorys.put(recent);
      }
    });
  }

  Future<void> deleteEntry(int id) async {
    await Storage.db.writeTxn(() async {
      await Storage.db.localHistorys.delete(id);
    });
  }

  Future<void> clearAll() async {
    await Storage.db.writeTxn(() async {
      await Storage.db.localHistorys.clear();
    });
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<LocalHistory>>(HistoryNotifier.new);
