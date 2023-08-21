import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stolarczyk_app/widgets/chat_messages.dart';
import 'package:stolarczyk_app/widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  static String routeName = '/chat';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotificatins() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    //final token = await fcm.getToken();
    //print(token);
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();

    setupPushNotificatins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat ogólny'),
        centerTitle: false,
      ),
      body: const Center(
        child: Column(children: [
          Expanded(child: ChatMessages()),
          NewMessage(),
        ]),
      ),
    );
  }
}
