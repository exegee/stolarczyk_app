import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stolarczyk_app/models/subscription.dart';
import 'package:stolarczyk_app/providers/db.dart';
import 'package:stolarczyk_app/screens/new_topic_screen.dart';
import 'package:stolarczyk_app/screens/overview_screen.dart';
import 'package:stolarczyk_app/screens/topic_detail_screen.dart';
import 'package:stolarczyk_app/screens/topics_screen.dart';
import 'package:stolarczyk_app/widgets/bottom_nav_bar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("onBackgroundMessage: ${message.data}");
}

class MainScreen extends ConsumerStatefulWidget {
  static String routeName = '/main';
  const MainScreen({
    super.key,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  Widget screen = const OverviewScreen();

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
    // Initialize date formatting to pl locale
    initializeDateFormatting('pl_PL', null);
    timeago.setLocaleMessages('pl', timeago.PlMessages());

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('cost tammamdadsm amsd asdm asdma');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("onMessageOpenedApp: ${message.data}");

      final topicId = message.data['data'];
      //final route = message.data['screen'];
      await DbProvider.getTopicByuId(topicId).then((value) {
        value.uid = topicId;
        Navigator.pushNamed(
          context,
          TopicDetailScreen.routeName,
          arguments: value,
        );
      });
    });
  }

  void setupPushNotifications() async {
    var notificationStatus = await Permission.notification.status;

    if (notificationStatus.isDenied) {
      await Permission.notification.request();
      await Permission.audio.request();
    }
    await Future.delayed(const Duration(seconds: 4));
    final user = await DbProvider.getAuthenticatedUser();
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    //var token = await fcm.getToken();
    // print(token);
    var topicsToSubscribe = await DbProvider.getUserSubsctiptions(user!.uid!);
    await fcm.getToken();

    for (Subscription subscription in topicsToSubscribe) {
      //print(subscription.topicId);
      fcm.subscribeToTopic(subscription.topicId);
    }
  }

  test(RemoteMessage message) async {
    final topicId = message.data['data'] as String;
    //print(topicId);
    final topic = await DbProvider.getTopicByuId(topicId);
    //print(topic.name);
    () {
      Navigator.pushNamed(
        context,
        TopicDetailScreen.routeName,
        arguments: topic,
      );
    };
  }

  navigateToNewTopicScreen() async {
    await Navigator.pushNamed(context, NewTopicScreen.routeName) as bool;
    ref.read(newTopicProvider.notifier).newTopic();
    //print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen,
      bottomNavigationBar: BottomNavBar(
        pageHandler: (selectedScreen) => setState(
          () {
            if (selectedScreen.keys.first == 2) {
              //  Navigator.pushNamed(context, NewTopicScreen.routeName);
              navigateToNewTopicScreen();
            } else {
              screen = selectedScreen.values.first;
            }
          },
        ),
      ),
    );
  }
}
