import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stolarczyk_app/extensions/intExtension.dart';
import 'package:stolarczyk_app/models/appUser.dart';
import 'package:stolarczyk_app/models/topic_comment.dart';
import 'package:stolarczyk_app/providers/db.dart';
import 'package:stolarczyk_app/screens/topic_comment_reply_screen.dart';
import 'package:stolarczyk_app/widgets/comment.dart';
import 'package:stolarczyk_app/widgets/new_task.dart';
import 'package:stolarczyk_app/widgets/new_topic_comment.dart';
import '../models/task.dart';
import '../models/topic.dart';
import '../widgets/placeholders.dart';

class TopicDetailScreen extends ConsumerStatefulWidget {
  const TopicDetailScreen({super.key, required this.topic});
  static const routeName = '/topic-detail';
  final Topic topic;
//todo: PRZEROBIC topic jako parametr wejsciowy na topicuid. ilosc komentarzy jest zczytywana z topic przekazywanego z poprzedniego okna a nie z db
// pobierac topic z bazy w init!!!
  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen> {
  bool toggle = false;
  Timer? countDownTimer;
  Duration? dateToEnd;
  bool _isFinished = false;
  bool _isLoadingTasks = false;
  bool _isLoadingComments = false;
  bool _isLoadingTopic = false;
  List<Task> tasks = [];
  Stream<QuerySnapshot<Map<String, dynamic>>>? topicCommentsStream;
  Map<String, TopicComment?> firstCommentsReplies = {};
  Map<String, int> commentsRepliesCount = {};
  int topicTasksCount = 0;
  Topic topic = Topic.empty();
  AppUser? user;

  void setupPushNotificatins() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    // final token = await fcm.getToken();
    // Subskrybowac liste topicow przy ladowaniu !!!???
    fcm.subscribeToTopic(widget.topic.uid!);
  }

  @override
  void initState() {
    _init();
    startCountDownTimer();
    super.initState();
    //setupPushNotificatins();
  }

  @override
  void dispose() {
    //stopCountDownTimer();
    super.dispose();
  }

  void startCountDownTimer() {
    dateToEnd = widget.topic.deadline.difference(DateTime.now());
    // print('date to end: ${dateToEnd!.inSeconds}');
    if (dateToEnd!.inSeconds > 0) {
      countDownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setCountDown();
      });
    } else {
      dateToEnd = Duration.zero;
      // print('date to end is zero: $dateToEnd');
      _isFinished = true;
    }
  }

  void stopCountDownTimer() {
    if (mounted) {
      setState(() {
        countDownTimer!.cancel();
      });
    }
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    if (mounted) {
      setState(() {
        final seconds = dateToEnd!.inSeconds - reduceSecondsBy;
        if (seconds < 0) {
          countDownTimer!.cancel();
        } else {
          dateToEnd = Duration(seconds: seconds);
        }
      });
    }
  }

  _showAddTaskModal() async {
    await showModalBottomSheet<Task>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Wrap(children: [
            NewTask(
              topicUid: widget.topic.uid,
            )
          ]),
        );
      },
    ).then((addedTask) {
      if (addedTask == null) return;
      if (addedTask.uid != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dodano nowe zadanie!')));
        setState(() {
          tasks.add(addedTask);
        });
      }
    });
  }

  _deleteTask(Task task) async {
    var result = await DbProvider.removeTask(widget.topic.uid, task);
    if (result) {
      if (task.status) {
        DbProvider.decrementCompletedTasksCount(widget.topic.uid!);
      }
      setState(() {
        tasks.remove(task);
      });
      DbProvider.decrementTotalTasksCount(widget.topic.uid!);
    }
  }

  //Refresh topics list by swiping screen down
  Future<void> _refresh() async {
    _init();
    setState(() {});
  }

  Future<void> _init() async {
    // Load topic tasks
    _isLoadingTasks = true;
    _isLoadingComments = true;
    _isLoadingTopic = true;
    topic = await DbProvider.getTopicByuId(widget.topic.uid!).then((topic) {
      setState(() {
        _isLoadingTopic = false;
      });

      // print('topic name: ${topic.name}');
      return topic;
    });
    topic.uid = widget.topic.uid!;
    topicTasksCount = await DbProvider.getTopicTaskCount(topic.uid);
    tasks = await DbProvider.getTopicTasks(topic.uid).whenComplete(() {
      // print('finished loading tasks');
      setState(() {
        _isLoadingTasks = false;
      });
    });

    // Get topic comments stream
    topicCommentsStream = DbProvider.topicCommentStream(topic.uid);
    topicCommentsStream!.first.then((snapshot) async {
      for (var comment in snapshot.docs) {
        var firstCommentReply =
            await DbProvider.getLatestTopicCommentReply(topic.uid, comment.id);
        var commentReplyCount =
            await DbProvider.getTopicCommentReplyCount(topic.uid, comment.id);

        if (firstCommentReply != null) {
          firstCommentsReplies
              .addEntries({MapEntry(comment.id, firstCommentReply)});
        }

        commentsRepliesCount
            .addEntries({MapEntry(comment.id, commentReplyCount)});
      }
    }).whenComplete(() {
      setState(() {
        _isLoadingComments = false;
      });

      // print('finished loading comments');
    });

    // Load user info and update provider
    await DbProvider.getAuthenticatedUser().then((value) {
      Future.delayed(Duration.zero).then((_) {
        // print('finished loading authenticated user');
        ref.read(appUserProvider.notifier).modify(value!);
      });
    });
    // print('done init');
  }

  @override
  Widget build(BuildContext context) {
    final dateCreated =
        DateFormat('dd.MM.yyyy', 'pl_PL').format(topic.dateCreated);
    final deadlineDate =
        DateFormat('dd.MM.yyyy', 'pl_PL').format(topic.deadline);
    final totalDays = topic.deadline.difference(topic.dateCreated).inDays;

    // print('total days: $totalDays');
    // final user = ref.watch(appUserProvider);
    final daysLeft = dateToEnd!.inDays;
    final hoursLeft = dateToEnd!.inHours.remainder(24);
    final minutesLeft = dateToEnd!.inMinutes.remainder(60);
    final secondsLeft = dateToEnd!.inSeconds.remainder(60);
    // print('days left: $daysLeft');
    // print('hours: $hoursLeft');
    // print('minutes: $minutesLeft');
    // print('seconds: $secondsLeft');
    int commentsCount = topic.commentsCount;
    //int commentsCount = ref.watch(topicProvider).commentsCount;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _showAddTaskModal();
              },
              icon: const Icon(Icons.add_circle),
              color: Theme.of(context).colorScheme.primary)
        ],
      ),
      // Display new comment for this topic
      bottomNavigationBar: BottomAppBar(
          child: NewTopicComment(
        onNewCommentSend: () {
          setState(() {
            topic.commentsCount++;
          });
        },
        topicUid: widget.topic.uid!,
      )),
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _isLoadingTopic
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade50,
                        enabled: true,
                        child: const Column(
                          children: [
                            TextPlaceholder(width: 200, height: 28),
                            TextPlaceholder(width: 200, height: 18),
                            SizedBox(
                              height: 24,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    TextPlaceholder(width: 100, height: 12),
                                    TextPlaceholder(width: 100, height: 12),
                                  ],
                                ),
                                Column(
                                  children: [
                                    TextPlaceholder(width: 100, height: 12),
                                    TextPlaceholder(width: 100, height: 12)
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 38,
                            ),
                            SizedBox(
                              width: 165,
                              height: 165,
                              child: CircleAvatar(),
                            ),
                            SizedBox(
                              height: 55,
                            )
                          ],
                        ))
                    : Column(
                        children: [
                          Text(
                            widget.topic.name,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            widget.topic.longDescription,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Utworzono',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(dateCreated),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Termin',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(deadlineDate),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: 250,
                                height: 250,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                              center: Alignment.center,
                                              stops: [
                                                0.45,
                                                1
                                              ],
                                              colors: [
                                                Color.fromARGB(
                                                    255, 226, 226, 226),
                                                Colors.white
                                              ])),
                                    ),
                                    Center(
                                      child: SizedBox(
                                        width: 160,
                                        height: 160,
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.grey[400],
                                          value: _isFinished
                                              ? 1.0
                                              : daysLeft == 0
                                                  ? 0.0
                                                  : (daysLeft / totalDays),
                                          strokeWidth: 10.0,
                                          color: Colors.green[900],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: SizedBox(
                                        width: 142,
                                        height: 142,
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.grey[400],
                                          value: _isFinished
                                              ? 1
                                              : hoursLeft == 0
                                                  ? 0.0
                                                  : hoursLeft / 24,
                                          strokeWidth: 8.0,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: SizedBox(
                                        width: 128,
                                        height: 128,
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.grey[400],
                                          value: _isFinished
                                              ? 1
                                              : minutesLeft == 0
                                                  ? 0.0
                                                  : minutesLeft / 60,
                                          strokeWidth: 6.0,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: SizedBox(
                                        width: 118,
                                        height: 118,
                                        child: CircularProgressIndicator(
                                            backgroundColor: Colors.grey[400],
                                            value: _isFinished
                                                ? 1
                                                : secondsLeft == 0
                                                    ? 0.0
                                                    : secondsLeft / 60,
                                            strokeWidth: 4.0,
                                            color: Colors.green[400]),
                                      ),
                                    ),
                                    Center(
                                      child: _isFinished
                                          ? const Text('Ukończono')
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('$daysLeft dni'),
                                                Text('$hoursLeft g.'),
                                                Text('$minutesLeft min.'),
                                                Text(
                                                  '$secondsLeft',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                // Tasks card
                // If loading tasks show shimmer effect
                _isLoadingTasks
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade50,
                        enabled: true,
                        child: const Card(
                          elevation: 4,
                          child: Column(children: [
                            SizedBox(
                              height: 100,
                              width: double.infinity,
                            )
                          ]),
                        ),
                      )
                    // Tasks card
                    : Card(
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10, left: 18),
                              child: Text(
                                "$topicTasksCount ${topicTasksCount.taskPlural().toUpperCase()}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const Divider(),
                            tasks.isEmpty
                                ? const SizedBox(
                                    height: 50,
                                    child: Center(
                                        child: Text(
                                      'Brak zadań.',
                                    )),
                                  )
                                : ListView.separated(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    primary: false,
                                    itemCount: tasks.length,
                                    itemBuilder: (context, index) {
                                      topicTasksCount = tasks.length;
                                      return ClipRRect(
                                        clipBehavior: Clip.hardEdge,
                                        child: Dismissible(
                                          direction:
                                              DismissDirection.endToStart,
                                          key: Key(tasks[index].uid!),
                                          dismissThresholds: const {
                                            DismissDirection.endToStart: 0.6
                                          },
                                          onDismissed: (direction) {
                                            _deleteTask(tasks[index]);
                                          },
                                          background: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              alignment: Alignment.centerRight,
                                              decoration: BoxDecoration(
                                                  color: Colors.red[300],
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          bottomLeft: Radius
                                                              .circular(12),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  12))),
                                              child: const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              )),
                                          child: CheckboxListTile(
                                            activeColor: Colors.green[600],
                                            title: Text(
                                              tasks[index].name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            //subtitle: Text(tasks[index].description),
                                            value: tasks[index].status,
                                            onChanged: (value) async {
                                              await DbProvider.toggleTopicTask(
                                                  widget.topic.uid,
                                                  tasks[index]);
                                              if (value!) {
                                                await DbProvider
                                                    .incrementCompletedTasksCount(
                                                        widget.topic.uid!);
                                              } else {
                                                await DbProvider
                                                    .decrementCompletedTasksCount(
                                                        widget.topic.uid!);
                                              }

                                              setState(() {
                                                tasks[index].status = value;
                                              });
                                            },
                                            secondary: Icon(
                                              Icons.task_alt,
                                              color: tasks[index].status
                                                  ? Colors.green[600]
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        const Divider(),
                                  ),
                          ],
                        ),
                      ),
                // Comments Card
                // Show shimmer effect when loading comments
                _isLoadingComments
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade50,
                        enabled: true,
                        child: const Card(
                          elevation: 4,
                          child: Column(children: [
                            SizedBox(
                              height: 100,
                              width: double.infinity,
                            )
                          ]),
                        ),
                      )
                    // Show comments Card
                    : Card(
                        elevation: 4,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Show total comments count
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, left: 18),
                                child: Text(
                                  "$commentsCount ${commentsCount.commentPlural().toUpperCase()}",
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              // Build comments stream
                              StreamBuilder(
                                stream: topicCommentsStream,
                                builder: (context, snapshot) {
                                  // Do nothinh when loading data
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {}
                                  // If data is empty show message
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const SizedBox(
                                      height: 60,
                                      child: Column(
                                        children: [
                                          Divider(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Center(
                                            child: Text('Brak komentarzy.'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  // Show on error
                                  if (snapshot.hasError) {
                                    return const SizedBox(
                                      height: 50,
                                      child: Center(
                                        child: Text('Coś poszło nie tak...'),
                                      ),
                                    );
                                  }
                                  // Build comments listview
                                  final loadedMessages = snapshot.data!.docs;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(
                                        left: 0, right: 0, bottom: 12),
                                    reverse: true,
                                    itemCount: loadedMessages.length,
                                    itemBuilder: (context, index) {
                                      final TopicComment topicComment =
                                          TopicComment.fromMap(
                                              loadedMessages[index].data());
                                      topicComment.uid =
                                          loadedMessages[index].id;
                                      final topicCommentReplyExist =
                                          firstCommentsReplies
                                              .containsKey(topicComment.uid);
                                      return Column(
                                        children: [
                                          // Show topic main comment
                                          const Divider(),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 12.0,
                                            ),
                                            child: Comment(
                                              // Update comments count on the UI
                                              onDeleteComment: (value) {
                                                setState(() {
                                                  topic.commentsCount -= value;
                                                });
                                              },
                                              topicComment: topicComment,
                                              topicUid: widget.topic.uid!,
                                              commentReply: true,
                                              showDivider: true,
                                            ),
                                          ),
                                          // Show "Odpowiedz" button - same function as "Zobacz odpowiedzi"
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 12),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () async {
                                                    await Navigator.pushNamed(
                                                        context,
                                                        TopicCommentReply
                                                            .routeName,
                                                        arguments: {
                                                          'topicComment':
                                                              topicComment,
                                                          'topicUid': topic.uid
                                                        }).then((value) {
                                                      // When going back from reply screen refresh topic detail screen
                                                      setState(() {
                                                        commentsCount++;
                                                      });
                                                      _refresh();
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.reply,
                                                    size: 14,
                                                  ),
                                                  label: const Text(
                                                    'Odpowiedz',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    foregroundColor:
                                                        Colors.grey[600],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),

                                          // If topic comment reply exist then show first comment reply and reply button
                                          topicCommentReplyExist
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 24.0),
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            border: Border(
                                                                left: BorderSide(
                                                                    width: 2,
                                                                    color: Colors
                                                                        .grey))),
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16),
                                                    child: Column(
                                                      children: [
                                                        Comment(
                                                          topicComment:
                                                              firstCommentsReplies[
                                                                  topicComment
                                                                      .uid]!,
                                                          topicUid:
                                                              widget.topic.uid!,
                                                          commentReply: false,
                                                          showDivider: false,
                                                        ),
                                                        Row(
                                                          children: [
                                                            // "Zobacz odpowiedzi" button
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                await Navigator.pushNamed(
                                                                    context,
                                                                    TopicCommentReply
                                                                        .routeName,
                                                                    arguments: {
                                                                      'topicComment':
                                                                          topicComment,
                                                                      'topicUid': widget
                                                                          .topic
                                                                          .uid!
                                                                    }).then(
                                                                    (value) {
                                                                  // When going back from reply screen refresh topic detail screen
                                                                  setState(() {
                                                                    commentsCount++;
                                                                  });
                                                                  _refresh();
                                                                });
                                                              },
                                                              style: TextButton
                                                                  .styleFrom(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(0),
                                                              ),
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                    "Zobacz odpowiedzi (${commentsRepliesCount[topicComment.uid]})"),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ]),
                      ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
