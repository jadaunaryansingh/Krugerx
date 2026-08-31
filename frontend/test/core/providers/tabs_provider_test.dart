import 'package:flutter_test/flutter_test.dart';
import 'package:krugerx/core/models/tab.dart';
import 'package:krugerx/core/providers/tabs_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('TabsNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('addTab creates a new tab and makes it active', () {
      final notifier = container.read(tabsProvider.notifier);
      final initialState = container.read(tabsProvider);
      
      notifier.addTab();
      
      final newState = container.read(tabsProvider);
      expect(newState.tabs.length, initialState.tabs.length + 1);
      expect(newState.activeIndex, newState.tabs.length - 1);
    });

    test('closeTab moves tab to closedTabs and updates activeIndex', () {
      final notifier = container.read(tabsProvider.notifier);
      
      notifier.addTab(); // tab 1
      notifier.addTab(); // tab 2
      
      final stateBefore = container.read(tabsProvider);
      expect(stateBefore.tabs.length, 3);
      
      final closedTab = stateBefore.tabs[1];
      
      notifier.closeTab(1);
      
      final stateAfter = container.read(tabsProvider);
      expect(stateAfter.tabs.length, 2);
      
      final closedTabsStack = notifier.closedTabs;
      expect(closedTabsStack.length, 1);
      expect(closedTabsStack.last.id, closedTab.id);
      expect(closedTabsStack.last.isMuted, true);
    });

    test('undoCloseTab restores the last closed tab at the end', () {
      final notifier = container.read(tabsProvider.notifier);
      notifier.addTab();
      
      final closedTab = container.read(tabsProvider).tabs.last;
      notifier.closeTab(1);
      
      expect(notifier.closedTabs.length, 1);
      
      notifier.undoCloseTab();
      
      final finalState = container.read(tabsProvider);
      expect(finalState.tabs.last.id, closedTab.id);
      expect(finalState.tabs.last.isMuted, false);
      expect(notifier.closedTabs.length, 0);
    });

    test('reorderTabs correctly reorders and maintains activeIndex', () {
      final notifier = container.read(tabsProvider.notifier);
      notifier.addTab(); // tab 1
      notifier.addTab(); // tab 2
      
      // Make tab 1 active
      notifier.switchTab(1);
      final activeTabId = container.read(tabsProvider).tabs[1].id;
      
      // Move tab 0 to end
      notifier.reorderTabs(0, 3);
      
      final stateAfter = container.read(tabsProvider);
      expect(stateAfter.tabs.last.id, container.read(tabsProvider).tabs[2].id);
      
      // Check active tab is still the same tab
      expect(stateAfter.tabs[stateAfter.activeIndex].id, activeTabId);
    });
  });
}
