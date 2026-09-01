import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/tab_model.dart';

const _uuid = Uuid();

const _desktopUA =
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

// ── State ─────────────────────────────────────────────────────────────────

class BrowserState {
  final List<TabModel> tabs;
  final int activeIndex;
  final bool showFindBar;
  final String findQuery;
  final int findMatchCount;
  final int findCurrentMatch;
  final bool showTabGrid;
  final bool showReaderMode;

  const BrowserState({
    required this.tabs,
    this.activeIndex = 0,
    this.showFindBar = false,
    this.findQuery = '',
    this.findMatchCount = 0,
    this.findCurrentMatch = 0,
    this.showTabGrid = false,
    this.showReaderMode = false,
  });

  TabModel get activeTab => tabs[activeIndex];

  BrowserState copyWith({
    List<TabModel>? tabs,
    int? activeIndex,
    bool? showFindBar,
    String? findQuery,
    int? findMatchCount,
    int? findCurrentMatch,
    bool? showTabGrid,
    bool? showReaderMode,
  }) =>
      BrowserState(
        tabs: tabs ?? this.tabs,
        activeIndex: activeIndex ?? this.activeIndex,
        showFindBar: showFindBar ?? this.showFindBar,
        findQuery: findQuery ?? this.findQuery,
        findMatchCount: findMatchCount ?? this.findMatchCount,
        findCurrentMatch: findCurrentMatch ?? this.findCurrentMatch,
        showTabGrid: showTabGrid ?? this.showTabGrid,
        showReaderMode: showReaderMode ?? this.showReaderMode,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────

class BrowserNotifier extends Notifier<BrowserState> {
  @override
  BrowserState build() => BrowserState(tabs: [TabModel(id: _uuid.v4())]);

  void addTab({bool incognito = false}) {
    final tab = TabModel(id: _uuid.v4(), isIncognito: incognito);
    state = state.copyWith(
      tabs: [...state.tabs, tab],
      activeIndex: state.tabs.length,
      showTabGrid: false,
    );
  }

  void closeTab(int index) {
    if (state.tabs.length <= 1) {
      // Don't close the last tab, just reset it
      final oldTab = state.tabs[0];
      _pushClosedTab(oldTab);
      state = BrowserState(tabs: [TabModel(id: _uuid.v4())]);
      return;
    }
    final tabs = [...state.tabs];
    final closedTab = tabs.removeAt(index);
    _pushClosedTab(closedTab);
    
    var next = state.activeIndex;
    if (index <= next) {
      next = (next - 1).clamp(0, tabs.length - 1);
    }
    state = state.copyWith(tabs: tabs, activeIndex: next);
  }

  void switchTab(int index) {
    if (index >= 0 && index < state.tabs.length && index != state.activeIndex) {
      state = state.copyWith(activeIndex: index, showTabGrid: false);
    }
  }

  void updateUrl(String url) {
    final tabs = [...state.tabs];
    tabs[state.activeIndex] = tabs[state.activeIndex].copyWith(url: url);
    state = state.copyWith(tabs: tabs);
  }

  void updateTitle(String title) {
    final tabs = [...state.tabs];
    tabs[state.activeIndex] = tabs[state.activeIndex].copyWith(title: title);
    state = state.copyWith(tabs: tabs);
  }

  void updateFavicon(String? faviconUrl) {
    final tabs = [...state.tabs];
    tabs[state.activeIndex] = tabs[state.activeIndex].copyWith(faviconUrl: faviconUrl);
    state = state.copyWith(tabs: tabs);
  }

  void toggleDesktopMode() {
    final tabs = [...state.tabs];
    final current = tabs[state.activeIndex];
    tabs[state.activeIndex] = current.copyWith(isDesktopMode: !current.isDesktopMode);
    state = state.copyWith(tabs: tabs);
  }

  void toggleNightMode() {
    final tabs = [...state.tabs];
    final current = tabs[state.activeIndex];
    tabs[state.activeIndex] = current.copyWith(isNightMode: !current.isNightMode);
    state = state.copyWith(tabs: tabs);
  }

  void setZoomLevel(double zoom) {
    final tabs = [...state.tabs];
    tabs[state.activeIndex] = tabs[state.activeIndex].copyWith(zoomLevel: zoom);
    state = state.copyWith(tabs: tabs);
  }

  // ── Phase A: Tab Management Foundation ──
  final List<TabModel> _closedTabsStack = [];

  void reorderTabs(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final tabs = [...state.tabs];
    final TabModel item = tabs.removeAt(oldIndex);
    tabs.insert(newIndex, item);
    
    // Update activeIndex so the same tab remains active
    int active = state.activeIndex;
    if (active == oldIndex) {
      active = newIndex;
    } else if (active > oldIndex && active <= newIndex) {
      active -= 1;
    } else if (active < oldIndex && active >= newIndex) {
      active += 1;
    }
    state = state.copyWith(tabs: tabs, activeIndex: active);
  }

  void togglePinTab(int index) {
    final tabs = [...state.tabs];
    final tab = tabs[index];
    tabs[index] = tab.copyWith(isPinned: !tab.isPinned);
    // Pinned tabs usually move to the front. For simplicity, just toggle for now.
    // Full logic: sort pinned tabs to the front.
    state = state.copyWith(tabs: tabs);
  }

  void toggleMuteTab(int index) {
    final tabs = [...state.tabs];
    final tab = tabs[index];
    tabs[index] = tab.copyWith(isMuted: !tab.isMuted);
    state = state.copyWith(tabs: tabs);
  }

  void _pushClosedTab(TabModel tab) {
    // Mute before pushing so it doesn't play audio
    final closedTab = tab.copyWith(isMuted: true);
    _closedTabsStack.add(closedTab);
    if (_closedTabsStack.length > 3) {
      _closedTabsStack.removeAt(0); // Max 3 zombie webviews
    }
  }

  TabModel? popClosedTab() {
    if (_closedTabsStack.isNotEmpty) {
      return _closedTabsStack.removeLast();
    }
    return null;
  }
  
  List<TabModel> get closedTabs => List.unmodifiable(_closedTabsStack);
  
  void undoCloseTab() {
    final tab = popClosedTab();
    if (tab != null) {
      // Unmute it when restored
      final restoredTab = tab.copyWith(isMuted: false);
      state = state.copyWith(
        tabs: [...state.tabs, restoredTab],
        activeIndex: state.tabs.length,
      );
    }
  }

  // ── Existing Toggles ──

  void toggleTabGrid() => state = state.copyWith(showTabGrid: !state.showTabGrid);
  void toggleReaderMode() => state = state.copyWith(showReaderMode: !state.showReaderMode);

  void openFindBar() => state = state.copyWith(showFindBar: true, findQuery: '', findMatchCount: 0, findCurrentMatch: 0);
  void closeFindBar() => state = state.copyWith(showFindBar: false, findQuery: '');
  void setFindQuery(String q) => state = state.copyWith(findQuery: q);
  void setFindResults(int total, int current) =>
      state = state.copyWith(findMatchCount: total, findCurrentMatch: current);

  String get activeDesktopUA => _desktopUA;
}

// ── Provider ──────────────────────────────────────────────────────────────

final browserProvider = NotifierProvider<BrowserNotifier, BrowserState>(BrowserNotifier.new);
