import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Navigation {
  final int? lastScreenIndexProvider;

  Navigation({this.lastScreenIndexProvider});
}

class NavigationNotifier extends StateNotifier<Navigation> {
  NavigationNotifier() : super(Navigation());

  void modifyLastScreenIndex(Navigation navigation) {
    state = navigation;
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, Navigation>((ref) {
  return NavigationNotifier();
});
