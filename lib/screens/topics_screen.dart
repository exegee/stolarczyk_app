import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stolarczyk_app/models/appUser.dart';
import 'package:stolarczyk_app/models/topic.dart';
import 'package:intl/intl.dart';
import 'package:stolarczyk_app/providers/db.dart';
import 'package:stolarczyk_app/screens/topic_detail_screen.dart';

import '../models/storage_item.dart';
import '../models/subscription.dart';
import '../providers/secure_storage.dart';

class TopicsScreen extends ConsumerStatefulWidget {
  static const routeName = '/topics';
  const TopicsScreen({super.key});

  @override
  ConsumerState<TopicsScreen> createState() => _TopicsScreenState();
}

int topicCommentCount = 0;
List<Topic> topicsList = [];
bool topicListLoading = false;
TextEditingController _topicSearchTextFieldController = TextEditingController();
String filter = '';
AppUser? user;
List<Subscription>? userSubs;
bool newTopicCreated = false;

class _TopicsScreenState extends ConsumerState<TopicsScreen> {
  @override
  void dispose() {
    //_topicSearchTextFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    topicListLoading = true;
    filter = '';
    _init();
    super.initState();
  }

  // Refresh topics list by swiping screen down
  Future<void> _refresh() async {
    if (mounted) {
      setState(() {});
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _init() async {
    user = await DbProvider.getAuthenticatedUser();
    userSubs = await DbProvider.getUserSubsctiptions(user!.uid!);

    var topicsSnapshot =
        await FirebaseFirestore.instance.collection('topics').get();
    return topicsSnapshot;
  }

  _toggleSubscribeToTopic(String topicUid) async {
    String? subToDelete;
    final isSubscribed = userSubs!.any((subscription) {
      if (subscription.topicId == topicUid) {
        subToDelete = subscription.id;
        return true;
      } else {
        subToDelete = null;
        return false;
      }
    });
    //print(isSubscribed);
    if (isSubscribed) {
      //print('removing sub');
      await DbProvider.deleteUserSubscription(subToDelete!);
    } else {
      await DbProvider.addUserSubscription(topicUid, user!.uid!);
    }
    userSubs = await DbProvider.getUserSubsctiptions(user!.uid!);
  }

  _deleteTopic(Topic topic) async {
    var result = await DbProvider.removeTopic(topic);

    if (result) {
      int topicsCount = await DbProvider.getTopicsCount();
      bool topicStatisticsExist =
          await SecureStorageProvider.containsKeyInSecureData(
              'topicsStatistics');
      if (topicStatisticsExist) {
        String? topicStatisticsRaw =
            await SecureStorageProvider.readSecuredStorage('topicsStatistics');
        List<dynamic> topicStatiscticsD = jsonDecode(topicStatisticsRaw!);
        List<double> topicStatisctics =
            topicStatiscticsD.map((e) => e as double).toList();
        topicStatisctics.add(topicsCount.toDouble());
        await SecureStorageProvider.writeSecureStorage(StorageItem(
            'topicsStatistics', (jsonEncode(topicStatisctics)).toString()));
      }
      setState(() {
        topicsList.remove(topic);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(newTopicProvider, (previous, next) {
      _refresh();
    });

    return Scaffold(
        // backgroundColor: Colors.grey[200],
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _topicSearchTextFieldController,
                onChanged: (value) {
                  setState(() {
                    filter = value;
                  });
                },
                decoration: InputDecoration(
                    hintText: 'Szukaj tematów...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          filter = '';
                          _topicSearchTextFieldController.clear();
                        });
                      },
                    ),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    border: InputBorder.none),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: FutureBuilder(
                future: _init(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Błąd pobierania danych"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // return const Center(child: CircularProgressIndicator());
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade50,
                      enabled: true,
                      child: ListView(
                        children: const [
                          Card(
                            child: SizedBox(
                              height: 110,
                              width: double.infinity,
                            ),
                          ),
                          Card(
                            child: SizedBox(
                              height: 110,
                              width: double.infinity,
                            ),
                          ),
                          Card(
                            child: SizedBox(
                              height: 110,
                              width: double.infinity,
                            ),
                          ),
                          Card(
                            child: SizedBox(
                              height: 110,
                              width: double.infinity,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    topicListLoading = false;
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.length < 1) {
                      //print('no data');
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverFillRemaining(
                              child: Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Text("Brak tematów. Utwórz jakieś!"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: CustomScrollView(
                        slivers: <Widget>[
                          SliverFillRemaining(
                            child: Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Text("Brak zadań. Utwórz jakieś!"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  topicsList = snapshot.data!.docs.map((snapshot) {
                    return Topic.fromSnapshot(snapshot);
                  }).toList();

                  return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        itemCount: topicsList.length,
                        itemBuilder: (context, index) {
                          // print(topicsList[index].subscribed);
                          var topicSubscribed = userSubs!.any((element) {
                            if (element.topicId == topicsList[index].uid) {
                              return true;
                            } else {
                              return false;
                            }
                          });
                          final dateCreated = DateFormat('dd.MM.yyyy', 'pl_PL')
                              .format(topicsList[index].dateCreated);
                          final deadlineDate = DateFormat('dd.MM.yyyy', 'pl_PL')
                              .format(topicsList[index].deadline);
                          if (filter.isEmpty) {
                            return Dismissible(
                              direction: DismissDirection.endToStart,
                              key: Key(topicsList[index].uid!),
                              dismissThresholds: const {
                                DismissDirection.endToStart: 0.6
                              },
                              onDismissed: (direction) {
                                _deleteTopic(topicsList[index]);
                              },
                              background: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    // side: BorderSide(
                                    //     color: Theme.of(context).colorScheme.outlineVariant),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 15),
                                  color: Colors.red[300]),
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  TopicDetailScreen.routeName,
                                  arguments: topicsList[index],
                                ),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    // side: BorderSide(
                                    //     color: Theme.of(context).colorScheme.outlineVariant),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 15),
                                  // color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                topicsList[index].name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18),
                                              ),
                                              Text(dateCreated),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            topicsList[index].shortDescription,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 15,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              topicsList[index]
                                                                  .createdBy
                                                                  .imagerUrl),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(topicsList[index]
                                                        .createdBy
                                                        .username),
                                                  ],
                                                ),
                                              ),
                                              StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Flexible(
                                                    flex: 2,
                                                    child: IconButton(
                                                        onPressed: () {
                                                          _toggleSubscribeToTopic(
                                                              topicsList[index]
                                                                  .uid!);
                                                          setState(() {
                                                            topicSubscribed =
                                                                !topicSubscribed;
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons.notifications,
                                                          size: 20,
                                                          color: topicSubscribed
                                                              // color: topicsList[index]
                                                              //         .subscribed!
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary
                                                              : Colors.black54,
                                                        )),
                                                  );
                                                },
                                              ),
                                              Flexible(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.messenger,
                                                      size: 20,
                                                      color: Colors.black54,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(topicsList[index]
                                                        .commentsCount
                                                        .toString()),
                                                  ],
                                                ),
                                              ),
                                              Flexible(
                                                  flex: 3,
                                                  child: Text(deadlineDate)),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            );
                          }
                          if (topicsList[index].name.startsWith(filter)) {
                            return Dismissible(
                              direction: DismissDirection.endToStart,
                              key: Key(topicsList[index].uid!),
                              dismissThresholds: const {
                                DismissDirection.endToStart: 0.6
                              },
                              onDismissed: (direction) {
                                _deleteTopic(topicsList[index]);
                              },
                              background: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    // side: BorderSide(
                                    //     color: Theme.of(context).colorScheme.outlineVariant),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 15),
                                  color: Colors.red[300]),
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  TopicDetailScreen.routeName,
                                  arguments: topicsList[index],
                                ),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    // side: BorderSide(
                                    //     color: Theme.of(context).colorScheme.outlineVariant),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 15),
                                  // color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                topicsList[index].name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18),
                                              ),
                                              Text(dateCreated),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            topicsList[index].shortDescription,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 15,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              topicsList[index]
                                                                  .createdBy
                                                                  .imagerUrl),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(topicsList[index]
                                                        .createdBy
                                                        .username),
                                                  ],
                                                ),
                                              ),
                                              Flexible(
                                                flex: 2,
                                                child: IconButton(
                                                    onPressed: () {
                                                      _toggleSubscribeToTopic(
                                                          topicsList[index]
                                                              .uid!);
                                                      setState(() {
                                                        topicSubscribed =
                                                            !topicSubscribed;
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.notifications,
                                                      size: 20,
                                                      color: topicSubscribed
                                                          // color: topicsList[index]
                                                          //         .subscribed!
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                          : Colors.black54,
                                                    )),
                                              ),
                                              Flexible(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.messenger,
                                                      size: 20,
                                                      color: Colors.black54,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(topicsList[index]
                                                        .commentsCount
                                                        .toString()),
                                                  ],
                                                ),
                                              ),
                                              Flexible(
                                                  flex: 3,
                                                  child: Text(deadlineDate)),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class TopicSearch extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var topic in topicsList) {
      if (topic.name.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(topic.name);
      }
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            title: Text(result),
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var topic in topicsList) {
      if (topic.name.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(topic.name);
      }
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            title: Text(result),
          );
        });
  }
}

class NewTopicNotifier extends StateNotifier<bool> {
  NewTopicNotifier() : super(false);

  void newTopic() {
    state = !state;
  }
}

final newTopicProvider = StateNotifierProvider<NewTopicNotifier, bool>((ref) {
  return NewTopicNotifier();
});
