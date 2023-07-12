import 'package:flutter/material.dart';
import 'package:stolarczyk_app/screens/new_topic_screen.dart';
import 'package:stolarczyk_app/screens/overview_screen.dart';
import 'package:stolarczyk_app/widgets/bottom_nav_bar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;

class MainScreen extends StatefulWidget {
  static String routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget screen = const OverviewScreen();

  @override
  void initState() {
    super.initState();
    // Initialize date formatting to pl locale
    initializeDateFormatting('pl_PL', null);
    timeago.setLocaleMessages('pl', timeago.PlMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen,
      bottomNavigationBar: BottomNavBar(
        pageHandler: (selectedScreen) => setState(
          () {
            if (selectedScreen.keys.first == 2) {
              Navigator.pushNamed(context, NewTopicScreen.routeName);
            } else {
              screen = selectedScreen.values.first;
            }
          },
        ),
      ),
    );
  }
}
