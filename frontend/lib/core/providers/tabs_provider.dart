import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:isar_community/isar.dart';

import '../../features/browser/models/tab_model.dart';
import '../storage.dart';
import '../../features/settings/models/settings_models.dart';
import '../../features/browser/models/session_models.dart';
import '../../features/history/providers/history_provider.dart';

class TabsState {
  final List<TabModel> tabs;
  final int activeIndex;
  final bool showFindBar;

  const TabsState({
    required this.tabs,
    this.activeIndex = 0,
    this.showFindBar = false,
  });

  TabModel? get activeTab =>
      tabs.isNotEmpty && activeIndex < tabs.length ? tabs[activeIndex] : null;

  TabsState copyWith({List<TabModel>? tabs, int? activeIndex, bool? showFindBar}) {
    return TabsState(
      tabs: tabs ?? this.tabs,
      activeIndex: activeIndex ?? this.activeIndex,
      showFindBar: showFindBar ?? this.showFindBar,
    );
  }
}

// Global registry for WebViewControllers mapped by tab ID
final Map<String, WebViewController> webViewControllers = {};

final tabsProvider = NotifierProvider<TabsNotifier, TabsState>(TabsNotifier.new);

class TabsNotifier extends Notifier<TabsState> {
  int _nextId = 1;
  bool _isSessionLoaded = false;
  final List<void Function()> _pendingActions = [];

  @override
  TabsState build() {
    Future.microtask(_loadSession);
    return const TabsState(tabs: []);
  }

  Future<void> _loadSession() async {
    final settings = await Storage.db.localSettings.get(1);
    final persistSession = settings?.persistSession ?? true;
    if (persistSession) {
      final savedTabs = await Storage.db.localSessionTabs.where().sortByPosition().findAll();
      if (savedTabs.isNotEmpty) {
        final tabs = savedTabs.map((s) => TabModel(
          id: s.tabId,
          sessionId: 'local',
          url: s.url,
          title: s.title ?? 'New Tab',
          pinned: s.isPinned,
          isMuted: s.isMuted,
          position: s.position,
          tabGroupId: s.groupId,
          zoomScale: s.zoomScale,
          active: true,
        )).toList();
        state = state.copyWith(tabs: tabs, activeIndex: 0);
        _nextId = tabs.map((t) => int.tryParse(t.id) ?? 0).fold(0, (a, b) => a > b ? a : b) + 1;
        return;
      }
    }
    state = state.copyWith(tabs: [
      TabModel(
        id: '0',
        sessionId: 'local',
        url: 'kruger://newtab',
        title: 'New Tab',
        active: true,
      ),
    ]);
    
    _isSessionLoaded = true;
    for (final action in _pendingActions) {
      action();
    }
    _pendingActions.clear();
  }

  void _saveSession() {
    Storage.db.localSettings.get(1).then((settings) {
      final persist = settings?.persistSession ?? true;
      Storage.db.writeTxn(() async {
        await Storage.db.localSessionTabs.clear();
        if (persist) {
          final models = state.tabs.asMap().entries.map((e) {
            final t = e.value;
            return LocalSessionTab()
              ..tabId = t.id
              ..url = t.url
              ..title = t.title
              ..timestamp = DateTime.now()
              ..isPinned = t.pinned
              ..isMuted = t.isMuted
              ..groupId = t.tabGroupId
              ..zoomScale = t.zoomScale
              ..position = e.key;
          }).toList();
          await Storage.db.localSessionTabs.putAll(models);
        }
      });
    });
  }

  void addTab({String url = 'kruger://newtab', String title = 'New Tab'}) {
    if (!_isSessionLoaded) {
      _pendingActions.add(() => addTab(url: url, title: title));
      return;
    }
    final newTab = TabModel(
      id: '${_nextId++}',
      sessionId: 'local',
      url: url,
      title: title,
      active: true,
    );
    final updatedTabs = [...state.tabs, newTab];
    state = state.copyWith(
      tabs: updatedTabs,
      activeIndex: updatedTabs.length - 1,
    );
    _saveSession();
  }

  final List<TabModel> _closedTabsStack = [];

  List<TabModel> get closedTabs => List.unmodifiable(_closedTabsStack);

  void _pushClosedTab(TabModel tab) {
    final closedTab = tab.copyWith(isMuted: true);
    _closedTabsStack.add(closedTab);
    if (_closedTabsStack.length > 3) {
      final removed = _closedTabsStack.removeAt(0); // Max 3 zombie webviews
      webViewControllers.remove(removed.id);
    }
  }

  TabModel? popClosedTab() {
    if (_closedTabsStack.isNotEmpty) {
      return _closedTabsStack.removeLast();
    }
    return null;
  }
  
  void undoCloseTab() {
    final tab = popClosedTab();
    if (tab != null) {
      final restoredTab = tab.copyWith(isMuted: false);
      final updatedTabs = [...state.tabs, restoredTab];
      state = state.copyWith(
        tabs: updatedTabs,
        activeIndex: updatedTabs.length - 1,
      );
      _saveSession();
    }
  }

  void reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final tabs = [...state.tabs];
    final TabModel item = tabs.removeAt(oldIndex);
    tabs.insert(newIndex, item);
    
    int active = state.activeIndex;
    if (active == oldIndex) {
      active = newIndex;
    } else if (active > oldIndex && active <= newIndex) {
      active -= 1;
    } else if (active < oldIndex && active >= newIndex) {
      active += 1;
    }
    state = state.copyWith(tabs: tabs, activeIndex: active);
    _saveSession();
  }

  void closeTab(int index) {
    if (state.tabs.length <= 1) {
      final oldTab = state.tabs[0];
      _pushClosedTab(oldTab);
      state = state.copyWith(
        tabs: [
          TabModel(
            id: '${_nextId++}',
            sessionId: 'local',
            url: 'kruger://newtab',
            title: 'New Tab',
            active: true,
          )
        ],
        activeIndex: 0,
      );
      _saveSession();
      return;
    }
    final tabs = [...state.tabs];
    final closedTab = tabs.removeAt(index);
    _pushClosedTab(closedTab);

    var newIndex = state.activeIndex;
    if (index <= newIndex && newIndex > 0) newIndex--;
    state = state.copyWith(tabs: tabs, activeIndex: newIndex);
    _saveSession();
  }

  void switchTab(int index) {
    if (index >= 0 && index < state.tabs.length) {
      state = state.copyWith(activeIndex: index);
    }
  }

  void toggleFindBar() {
    state = state.copyWith(showFindBar: !state.showFindBar);
  }

  void closeFindBar() {
    state = state.copyWith(showFindBar: false);
  }

  void toggleReaderMode(int index) {
    if (index >= 0 && index < state.tabs.length) {
      final tab = state.tabs[index];
      final newTabs = List<TabModel>.from(state.tabs);
      newTabs[index] = tab.copyWith(isReaderMode: !tab.isReaderMode);
      state = state.copyWith(tabs: newTabs);
    }
  }

  void updateTabUrl(int index, String url) {
    final updatedTabs = [...state.tabs];
    updatedTabs[index] = updatedTabs[index].copyWith(url: url);
    state = state.copyWith(tabs: updatedTabs);
    _saveSession();
    
    _addToHistory(url, updatedTabs[index].title);
  }

  void updateTabUrlById(String id, String url) {
    final index = state.tabs.indexWhere((t) => t.id == id);
    if (index != -1) updateTabUrl(index, url);
  }

  void updateTabTitle(int index, String title) {
    final updatedTabs = [...state.tabs];
    updatedTabs[index] = updatedTabs[index].copyWith(title: title);
    state = state.copyWith(tabs: updatedTabs);
    _saveSession();
    
    _updateHistoryTitle(updatedTabs[index].url, title);
  }

  void updateTabTitleById(String id, String title) {
    final index = state.tabs.indexWhere((t) => t.id == id);
    if (index != -1) updateTabTitle(index, title);
  }

  void updateTabZoomScale(int index, double scale) {
    if (index >= 0 && index < state.tabs.length) {
      final updatedTabs = [...state.tabs];
      updatedTabs[index] = updatedTabs[index].copyWith(zoomScale: scale);
      state = state.copyWith(tabs: updatedTabs);
      _saveSession();
      
      // Inject zoom JS immediately
      final controller = webViewControllers[updatedTabs[index].id];
      if (controller != null) {
        controller.runJavaScript("document.body.style.zoom = '$scale'");
      }
    }
  }

  void updateTabGroup(int index, String? groupId) {
    if (index >= 0 && index < state.tabs.length) {
      final updatedTabs = [...state.tabs];
      updatedTabs[index] = updatedTabs[index].copyWith(tabGroupId: groupId);
      state = state.copyWith(tabs: updatedTabs);
      _saveSession();
    }
  }
  
  void _addToHistory(String url, String? title) {
    if (url.startsWith('kruger://') || url.isEmpty || url == 'about:blank') return;
    
    ref.read(historyProvider.notifier).recordVisit(url, title: title);
  }
  
  void _updateHistoryTitle(String url, String title) {
    if (url.startsWith('kruger://') || url.isEmpty || url == 'about:blank') return;
    
    ref.read(historyProvider.notifier).updateTitle(url, title);
  }
}

