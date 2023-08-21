import 'package:drop_shadow_image/drop_shadow_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stolarczyk_app/screens/signup_screen.dart';

final _firebase = FirebaseAuth.instance;

class SignInScreen extends ConsumerStatefulWidget {
  static const routeName = '/signin';
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isAuthenticating = false;

  Future<void> _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      // show error message ...
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);
      // if (mounted) {
      //   await DbProvider.getAuthenticatedUser().then((value) {
      //     if (mounted) {
      //       ref.read(appUserProvider.notifier).modify(value!);
      //     }
      //   });
      // }

      //     await SecureStorageProvider.writeSecureStorage(
      //     StorageItem('username', _enteredUsername));
      // await SecureStorageProvider.writeSecureStorage(
      //     StorageItem('imageUrl', imageUrl));
      // await SecureStorageProvider.writeSecureStorage(
      //     StorageItem('email', _enteredEmail));
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
      setState(() {
        _isAuthenticating = false;
      });

      // await SecureStorageProvider.writeSecureStorage(
      //     StorageItem('email', user.email));
      // await SecureStorageProvider.writeSecureStorage(
      //     StorageItem('imageUrl', user.imagerUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                TextFormField(
                  style: const TextStyle(
                      fontSize: 14.0, fontWeight: FontWeight.w400),
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  //initialValue: "test@test.com",
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: "Adres e-mail",
                    labelStyle: TextStyle(fontSize: 13.0, color: Colors.grey),
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
                    labelText: 'Hasło',
                    labelStyle: TextStyle(fontSize: 13.0, color: Colors.grey),
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
                      'Zaloguj',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                if (!_isAuthenticating)
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SignUpScreen.routeName);
                    },
                    child: const Text('Utwórz konto'),
                  ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
