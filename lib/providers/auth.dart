import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// TODO usunac ta klase ? getAuthenticatedUser mam juz w dbprovider
class Auth with ChangeNotifier {
  Future<String> getAuthenticatedUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final username = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) => value.data()!['username'].toString());
    return username;
  }
}
