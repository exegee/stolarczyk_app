import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stolarczyk_app/models/topic.dart';
import 'package:intl/intl.dart';
import 'package:stolarczyk_app/screens/topic_detail_screen.dart';

class TopicsScreen extends StatefulWidget {
  static const routeName = '/topics';
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

List<Topic> topicsList = [];

class _TopicsScreenState extends State<TopicsScreen> {
  @override
  void initState() {
    super.initState();
  }

  // Refresh topics list by swiping screen down
  Future<void> _refresh() async {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: InputDecoration(
                    hintText: 'Szukaj zadań',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {},
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
                future: FirebaseFirestore.instance.collection('topics').get(),
                //     .then((snapshot) async {
                //   List<Map<String, dynamic>> data = [];

                //   // For each topic get user image url from the user reference field
                //   for (var i = 0; i < snapshot.docs.length; i++) {
                //     var dataEntry = snapshot.docs[i].data();
                //     var topicId = snapshot.docs[i].id;
                //     dataEntry.addEntries([MapEntry('uid', topicId)]);
                //     data.add(dataEntry);
                //   }
                //   return Future.value(data);
                // }),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Błąd pobierania danych"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // print(snapshot.data);
                  // topicsList = snapshot.data!.map((topic) {
                  //   return Topic.fromMap(topic);
                  // }).toList();
                  topicsList = snapshot.data!.docs.map((snapshot) {
                    return Topic.fromSnapshot(snapshot);
                  }).toList();

                  // topicsList = snapshot.data!.docs
                  //     .map((topic) => Topic.fromMap(topic.data()))
                  //     .toList();
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      itemCount: topicsList.length,
                      itemBuilder: (context, index) {
                        final dateCreated = DateFormat('dd.MM.yyyy', 'pl_PL')
                            .format(topicsList[index].dateCreated);
                        final deadlineDate = DateFormat('dd.MM.yyyy', 'pl_PL')
                            .format(topicsList[index].deadline);
                        return GestureDetector(
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
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                backgroundImage: NetworkImage(
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
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.notifications,
                                                size: 20,
                                                color: Colors.black54,
                                              )),
                                        ),
                                        const Flexible(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.messenger,
                                                size: 20,
                                                color: Colors.black54,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text('5'),
                                            ],
                                          ),
                                        ),
                                        Flexible(
                                            flex: 3, child: Text(deadlineDate)),
                                      ],
                                    ),
                                  ]),
                            ),
                          ),
                        );
                      },
                    ),
                  );
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
