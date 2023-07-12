import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stolarczyk_app/models/appUser.dart';
import 'package:stolarczyk_app/models/storage_item.dart';
import 'package:stolarczyk_app/providers/db.dart';

import '../providers/secure_storage.dart';

class OverviewScreen extends ConsumerStatefulWidget {
  static const routeName = '/overview';
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  @override
  void initState() {
    super.initState();
  }

  // Initialize some basic values
  Future<AppUser?> init() async {
    AppUser? user = AppUser.init();

    // Get user info from Firebase
    user = await DbProvider.getAuthenticatedUser();
    ref.read(appUserProvider.notifier).modify(user!);
    await SecureStorageProvider.writeSecureStorage(
        StorageItem('username', user!.username));
    await SecureStorageProvider.writeSecureStorage(
        StorageItem('uid', user.uid as String));
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return const Center(child: Text("Błąd pobierania danych"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Witaj ${snapshot.data!.username}'),
            centerTitle: false,
          ),
          body: const Center(
            child: Text('Overview Screen!'),
          ),
        );
      },
    );
  }
}
