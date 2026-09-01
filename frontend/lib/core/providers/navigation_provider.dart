import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNavigationObserver extends NavigatorObserver {
  final Ref ref;
  
  AppNavigationObserver(this.ref);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      ref.read(navigationProvider.notifier).pushRoute(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    ref.read(navigationProvider.notifier).popRoute();
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != null) {
      ref.read(navigationProvider.notifier).replaceRoute(newRoute!.settings.name!);
    }
  }
}

class NavigationState {
  final List<String> history;
  final int currentIndex;

  const NavigationState({
    required this.history,
    required this.currentIndex,
  });

  bool get canGoBack => currentIndex > 0;
  bool get canGoForward => currentIndex < history.length - 1;
  String? get previousRoute => canGoBack ? history[currentIndex - 1] : null;
  String? get nextRoute => canGoForward ? history[currentIndex + 1] : null;
}

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    return const NavigationState(history: [], currentIndex: -1);
  }

  void pushRoute(String route) {
    // If we're not at the end of the history stack and we push a new route,
    // we truncate the forward history.
    final currentHistory = state.history;
    final currentIndex = state.currentIndex;
    
    if (currentIndex >= 0 && currentHistory[currentIndex] == route) {
      return; // Ignore duplicate pushes
    }

    final newHistory = currentHistory.sublist(0, currentIndex + 1)..add(route);
    state = NavigationState(history: newHistory, currentIndex: newHistory.length - 1);
  }

  void popRoute() {
    if (state.canGoBack) {
      state = NavigationState(history: state.history, currentIndex: state.currentIndex - 1);
    }
  }
  
  void replaceRoute(String route) {
    if (state.history.isEmpty) {
      pushRoute(route);
      return;
    }
    
    final newHistory = List<String>.from(state.history);
    newHistory[state.currentIndex] = route;
    state = NavigationState(history: newHistory, currentIndex: state.currentIndex);
  }
  
  // These methods are meant to be called by the UI to trigger navigation,
  // returning the route to go to. The actual GoRouter.go() should be called by the UI.
  String? getBackRoute() {
    if (state.canGoBack) {
      // The pop event will be caught by the observer, updating the index
      return state.history[state.currentIndex - 1];
    }
    return null;
  }
  
  String? getForwardRoute() {
    if (state.canGoForward) {
      // Since GoRouter doesn't have a 'forward', we must push/go the next route.
      // But going will trigger didPush, wiping our forward history!
      // To fix this, we'd need to manually adjust the index.
      // For simplicity, we just use the index shift.
      final route = state.history[state.currentIndex + 1];
      state = NavigationState(history: state.history, currentIndex: state.currentIndex + 1);
      return route;
    }
    return null;
  }
}

final navigationProvider = NotifierProvider<NavigationNotifier, NavigationState>(NavigationNotifier.new);
