import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stolarczyk_app/models/appUser.dart';
import 'package:stolarczyk_app/providers/db.dart';
import 'package:stolarczyk_app/widgets/products_list_item.dart';

import '../models/product.dart';
import '../providers/secure_storage.dart';

class OverviewScreen extends ConsumerStatefulWidget {
  static const routeName = '/overview';
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen>
    with SingleTickerProviderStateMixin {
  bool retry = true;
  String? username;
  AppUser user = AppUser.init();
  int topicsCount = 0;
  List<dynamic> topicStatisctics = [0.0];
  static List<Product> products = [
    Product(
        name: 'RS0.8',
        description: 'Rozwijacz',
        imageUrl:
            'https://spolkastolarczyk.pl/uploads/products/18/123/c3b804669b2909352c745cc559d22484.jpg'),
    Product(
        name: 'RS02',
        description: 'Rozwijacz',
        imageUrl:
            'https://spolkastolarczyk.pl/uploads/products/8/125/18cee984936b0f3cf4915bf833d1d367.jpg'),
    Product(
        name: 'RS05H',
        description: 'Rozwijacz',
        imageUrl:
            'https://spolkastolarczyk.pl/uploads/products/18/123/c3b804669b2909352c745cc559d22484.jpg'),
    Product(
        name: 'RS05HW-D',
        description: 'Rozwijacz',
        imageUrl:
            'https://spolkastolarczyk.pl/uploads/products/20/129/5756f8eceb13971d12802bd011f9c160.jpg'),
    Product(
        name: 'RS10Hp',
        description: 'Rozwijacz',
        imageUrl:
            'https://spolkastolarczyk.pl/uploads/products/22/130/b38fdc0d4ef040155d6d663717b23720.jpg'),
    Product(
        name: 'RS10HWOPp',
        description: 'Rozwijacz',
        imageUrl:
            'https://spolkastolarczyk.pl/uploads/products/26/133/6a2e05d63776fd932b917c6e97212c54.jpg'),
  ];

  @override
  void initState() {
    //init();
    getTopicsCount();
    super.initState();
  }

  getTopicsCount() async {
    //print(topicStatisctics);
    if (topicStatisctics.length < 2) {
      var topicCount = await DbProvider.getTopicsCount();
      topicStatisctics.add(topicCount.toDouble());
    }

    bool topicStatisticsExist =
        await SecureStorageProvider.containsKeyInSecureData('topicsStatistics');
    if (topicStatisticsExist) {
      String? topicStatisticsRaw =
          await SecureStorageProvider.readSecuredStorage('topicsStatistics');
      topicStatisctics = jsonDecode(topicStatisticsRaw!);
    }
    //print(topicStatisctics);
  }

  // Initialize some basic values
  Future<AppUser?> init() async {
    // AppUser? user = AppUser.init();
    // await Future.delayed(const Duration(milliseconds: 1000), () async {
    //   // Get user info from Firebase
    await DbProvider.getAuthenticatedUser().then((value) {
      user = value!;
    });
    topicsCount = await DbProvider.getTopicsCount();
    //print(user!.username);

    //ref.read(appUserProvider.notifier).modify(user!);
    //   await SecureStorageProvider.writeSecureStorage(
    //       StorageItem('username', user!.username));
    //   await SecureStorageProvider.writeSecureStorage(
    //       StorageItem('uid', user!.uid as String));
    // });

    // Load user info and update provider
    await DbProvider.getAuthenticatedUser().then((value) {});
    return Future.value(user);

    // var username = await SecureStorageProvider.readSecuredStorage('username');
    // var uid = await SecureStorageProvider.readSecuredStorage('uid');
    // var email = await SecureStorageProvider.readSecuredStorage('email');
    // user = ref.watch(appUserProvider);
    // setState(() {
    // user.username = username!;
    // user.uid = uid;
    // });

    //user.email = email!;
    // print(username);
    // AppUser user =
    //     AppUser(username: username!, uid: uid, email: email!, imagerUrl: '');
    // print(user);
    //return user;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    username = ref.watch(appUserProvider).username;
    // ref.read(appUserProvider.notifier).modify(user!);
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No data'),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Błąd pobierania danych"));
        }

        return Scaffold(
          appBar: AppBar(
            title: snapshot.hasData
                ? Text('Witaj ${snapshot.data!.username}')
                : Text('Witaj $username'),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                for (final Product product in products)
                  ProductsListItem(
                    imageUrl: product.imageUrl,
                    name: product.name,
                    description: product.description,
                  ),
              ],
            ),
          ),
          // body: Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Column(
          //     children: [
          //       Card(
          //         child: Padding(
          //           padding: const EdgeInsets.symmetric(
          //               horizontal: 12, vertical: 12),
          //           child: Column(
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.symmetric(horizontal: 0.0),
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                   children: [
          //                     // Icon(
          //                     //   Icons.topic,
          //                     //   color: Theme.of(context).primaryColor,
          //                     // ),
          //                     Text(
          //                       'Zadania',
          //                       style: TextStyle(fontSize: 20),
          //                     ),
          //                     Text(
          //                       topicsCount.toString(),
          //                       style: TextStyle(fontSize: 20),
          //                     ),
          //                     SizedBox(
          //                       width: 125,
          //                       height: 50,
          //                       child: Sparkline(
          //                         data: topicStatisctics
          //                             .map((e) => e as double)
          //                             .toList(),
          //                         // backgroundColor: Colors.red,
          //                         //lineColor: Colors.lightGreen[900]!,
          //                         fillMode: FillMode.below,
          //                         //fillColor: Colors.lightGreen[100]!,
          //                         // pointsMode: PointsMode.all,
          //                         // pointSize: 5.0,
          //                         // pointColor: Colors.amber,
          //                         useCubicSmoothing: true,
          //                         lineWidth: 2.0,
          //                         // gridLinelabelPrefix: '\$',
          //                         // gridLineLabelPrecision: 3,
          //                         // enableGridLines: true,
          //                         averageLine: false,
          //                         averageLabel: false,
          //                         // kLine: ['max', 'min', 'first', 'last'],
          //                         // // max: 50.5,
          //                         // // min: 10.0,
          //                         enableThreshold: true,
          //                         thresholdSize: 0.1,
          //                         lineGradient: LinearGradient(
          //                           begin: Alignment.topCenter,
          //                           end: Alignment.bottomCenter,
          //                           colors: [
          //                             Colors.blue[800]!,
          //                             Colors.blue[400]!
          //                           ],
          //                         ),
          //                         fillGradient: LinearGradient(
          //                           begin: Alignment.topCenter,
          //                           end: Alignment.bottomCenter,
          //                           colors: [Colors.blue[400]!, Colors.white],
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        );
      },
    );
    // var user = ref.watch(appUserProvider);
    // print(user.username);
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Witaj ${user.username}'),
    //     centerTitle: false,
    //   ),
    //   body: const Center(
    //     child: Text('Overview Screen!'),
    //   ),
    // );
  }
}
