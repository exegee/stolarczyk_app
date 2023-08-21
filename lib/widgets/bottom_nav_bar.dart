import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stolarczyk_app/providers/navigation.dart';
import 'package:stolarczyk_app/screens/account_screen.dart';
import 'package:stolarczyk_app/screens/chat_screen.dart';
import 'package:stolarczyk_app/screens/new_topic_screen.dart';
import 'package:stolarczyk_app/screens/topics_screen.dart';
import '../screens/overview_screen.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  final ValueSetter<Map<int, Widget>> pageHandler;

  const BottomNavBar({super.key, required this.pageHandler});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  int _selectedPageIndex = 0;
  List<Map<String, Object>> _screens = [];

  void _selectPage(int index) {
    if (index != 2) {
      setState(() {
        _selectedPageIndex = index;
      });
    }
    widget
        .pageHandler(<int, Widget>{index: _screens[index]['screen'] as Widget});
    ref.read(navigationProvider.notifier).modifyLastScreenIndex(
        Navigation(lastScreenIndexProvider: _selectedPageIndex));
  }

  @override
  void initState() {
    _screens = [
      {
        'screen': const OverviewScreen(),
        'title': 'Pulpit',
      },
      {
        'screen': const TopicsScreen(),
        'title': 'Tematy',
      },
      {
        'screen': const NewTopicScreen(),
        'title': 'Dodaj',
      },
      {
        'screen': const ChatScreen(),
        'title': 'Chat',
      },
      {
        'screen': const AccountScreen(),
        'title': 'Profil',
      },
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //_selectedPageIndex = ref.watch(navigationProvider).lastScreenIndexProvider;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      iconSize: 25,
      items: [
        BottomNavigationBarItem(
          icon:
              Icon(_selectedPageIndex == 0 ? Icons.home : Icons.home_outlined),
          label: 'Pulpit',
        ),
        BottomNavigationBarItem(
          icon: Icon(
              _selectedPageIndex == 1 ? Icons.topic : Icons.topic_outlined),
          label: 'Tematy',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _selectedPageIndex == 2 ? Icons.add : Icons.add_circle,
            size: 32,
          ),
          label: 'Dodaj',
        ),
        BottomNavigationBarItem(
          icon: Icon(_selectedPageIndex == 3
              ? Icons.chat_bubble
              : Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(_selectedPageIndex == 4
              ? Icons.account_circle
              : Icons.account_circle_outlined),
          label: 'Profil',
        ),
      ],
      currentIndex: _selectedPageIndex,
      onTap: _selectPage,
    );
  }
}
