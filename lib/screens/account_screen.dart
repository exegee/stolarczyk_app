import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  static const routeName = '/account';
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mój profil'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              //SecureStorageProvider.deleteAllData();
            },
            child: const Text('Wyloguj się'),
          )
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 30,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              width: 300,
              child: Image.asset('assets/images/logo.png'),
            ),
            Text(
              'W budowie...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    );
  }
}
