import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stolarczyk_app/models/topic.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:stolarczyk_app/screens/chat_screen.dart';
import 'package:stolarczyk_app/screens/main_screen.dart';
import 'package:stolarczyk_app/screens/new_topic_screen.dart';
import 'package:stolarczyk_app/screens/overview_screen.dart';
import 'package:stolarczyk_app/screens/signin_screen.dart';
import 'package:stolarczyk_app/screens/signup_screen.dart';
import 'package:stolarczyk_app/screens/splash_screen.dart';
import 'package:stolarczyk_app/screens/topic_comment_reply_screen.dart';
import 'package:stolarczyk_app/screens/topic_detail_screen.dart';
import 'package:stolarczyk_app/screens/topics_screen.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(child: StolarczykApp()),
  );
}

class StolarczykApp extends StatelessWidget {
  const StolarczykApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stolarczyk',
      // Define a theme
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        bottomAppBarTheme: const BottomAppBarTheme(
            elevation: 24,
            surfaceTintColor: Colors.white,
            shadowColor: Colors.black,
            color: Colors.white,
            padding: EdgeInsets.all(0),
            height: 65),
        cardTheme: const CardTheme(
            color: Colors.white, surfaceTintColor: Colors.white),
        useMaterial3: true,
      ),
      // Add localization and locale eg. for DatePicker
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pl'),
        Locale('en'),
      ],
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }

          return const SignInScreen();
        },
      ),
      // Routes with parameters
      onGenerateRoute: (settings) {
        // TopicScreenDetail on route generate function
        if (settings.name == TopicDetailScreen.routeName) {
          final args = settings.arguments as Topic;
          return MaterialPageRoute(
            builder: (context) {
              return TopicDetailScreen(
                topic: args,
              );
            },
          );
        }
        if (settings.name == TopicCommentReply.routeName) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(builder: (context) {
            return TopicCommentReply(
              topicComment: args['topicComment'],
              topicUid: args['topicUid'],
            );
          });
        }
        return MaterialPageRoute(
          builder: (context) {
            return const MainScreen();
          },
        );
      },
      // Static routes (without parameters)
      routes: {
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        SignInScreen.routeName: (context) => const SignInScreen(),
        TopicsScreen.routeName: (context) => const TopicsScreen(),
        MainScreen.routeName: (context) => const MainScreen(),
        NewTopicScreen.routeName: (context) => const NewTopicScreen(),
        OverviewScreen.routeName: (context) => const OverviewScreen(),
        ChatScreen.routeName: (context) => const ChatScreen(),
      },
      navigatorKey: navigatorKey,
    );
  }
}
