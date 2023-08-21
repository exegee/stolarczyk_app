import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stolarczyk_app/models/appUser.dart';
import 'package:stolarczyk_app/screens/signin_screen.dart';

import '../providers/navigation.dart';
import '../widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class SignUpScreen extends ConsumerStatefulWidget {
  static const routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  Future<void> _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || _selectedImage == null) {
      // show error message ...
      return;
    }
    //String imageUrl = '';
    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${userCredentials.user!.uid}.jpg');

      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        'username': _enteredUsername,
        'email': _enteredEmail,
        'imageUrl': imageUrl,
      }).whenComplete(() async {
        // await SecureStorageProvider.writeSecureStorage(
        //     StorageItem('username', _enteredUsername));
        // await SecureStorageProvider.writeSecureStorage(
        //     StorageItem('imageUrl', imageUrl));
        // await SecureStorageProvider.writeSecureStorage(
        //     StorageItem('email', _enteredEmail));
      });
      ref.read(appUserProvider.notifier).modify(AppUser(
          email: '', imagerUrl: imageUrl, username: _enteredUsername, uid: ''));
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // ...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Uwierzytelnianie nie powiodło się'),
        ),
      );
    }

    ref
        .read(navigationProvider.notifier)
        .modifyLastScreenIndex(Navigation(lastScreenIndexProvider: 0));

    setState(() {
      _isAuthenticating = false;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    height: 100,
                    width: 300,
                    child: DropShadowImage(
                      blurRadius: 10,
                      borderRadius: 2,
                      image: Image.asset('assets/images/logo.png'),
                    )),
                Form(
                  key: _form,
                  child: Column(children: [
                    UserImagePicker(
                      onPickImage: (pickedImage) {
                        _selectedImage = pickedImage;
                      },
                    ),
                    TextFormField(
                      style: const TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w400),
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      //initialValue: "test@test.com",
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                        labelText: "Adres e-mail",
                        labelStyle:
                            TextStyle(fontSize: 13.0, color: Colors.grey),
                        hintText: "Wprowadź adres e-mail",
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains('@')) {
                          return 'Wprowadź poprawny adres e-mail';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredEmail = value!;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Użytkownik',
                        labelStyle:
                            TextStyle(fontSize: 13.0, color: Colors.grey),
                        hintText: "Wprowadź nazwę użytkownika",
                      ),
                      enableSuggestions: false,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length < 4) {
                          return 'Wprowadź przynajmniej 4 znaki';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredUsername = value!;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Hasło',
                        labelStyle:
                            TextStyle(fontSize: 13.0, color: Colors.grey),
                        hintText: "Wprowadź hasło",
                      ),
                      //initialValue: "123456",
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return 'Hasło musi mieć przynajmniej 6 znaków';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredPassword = value!;
                      },
                    ),
                    const SizedBox(height: 36),
                    if (_isAuthenticating) const CircularProgressIndicator(),
                    if (!_isAuthenticating)
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer),
                        child: Text(
                          'Zarejestruj się',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    if (!_isAuthenticating)
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, SignInScreen.routeName);
                        },
                        child: const Text('Mam już konto'),
                      ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
