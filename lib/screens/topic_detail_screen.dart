import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stolarczyk_app/models/topic_comment.dart';
import 'package:stolarczyk_app/providers/db.dart';
import 'package:stolarczyk_app/widgets/comment.dart';
import 'package:stolarczyk_app/widgets/new_task.dart';
import 'package:stolarczyk_app/widgets/new_topic_comment.dart';
import '../models/task.dart';
import '../models/topic.dart';

class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({super.key, required this.topic});
  static const routeName = '/topic-detail';
  final Topic topic;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  bool toggle = false;
  Timer? countDownTimer;
  Duration? dateToEnd;
  bool _isFinished = false;
  bool _isLoadingTasks = false;
  List<Task> tasks = [];
  Stream<QuerySnapshot<Map<String, dynamic>>>? topicChatStream;

  @override
  void initState() {
    _init();
    startCountDownTimer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startCountDownTimer() {
    dateToEnd = widget.topic.deadline.difference(DateTime.now());
    if (dateToEnd!.inSeconds > 0) {
      countDownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setCountDown();
      });
    } else {
      dateToEnd = Duration.zero;
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
      setState(() {
        tasks.remove(task);
      });
    }
  }

  // Refresh topics list by swiping screen down
  // Future<void> _refresh() async {
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  Future<void> _init() async {
    //TODO: load some additional info about the topic like comments etc?
    _isLoadingTasks = true;
    tasks = await DbProvider.getTopicTasks(widget.topic.uid).whenComplete(() {
      _isLoadingTasks = false;
    });

    topicChatStream = DbProvider.topicChatStream(widget.topic.uid);
  }

  @override
  Widget build(BuildContext context) {
    final dateCreated =
        DateFormat('dd.MM.yyyy', 'pl_PL').format(widget.topic.dateCreated);
    final deadlineDate =
        DateFormat('dd.MM.yyyy', 'pl_PL').format(widget.topic.deadline);
    final totalDays =
        widget.topic.deadline.difference(widget.topic.dateCreated).inDays;

    final daysLeft = dateToEnd!.inDays;
    final hoursLeft = dateToEnd!.inHours.remainder(24);
    final minutesLeft = dateToEnd!.inMinutes.remainder(60);
    final secondsLeft = dateToEnd!.inSeconds.remainder(60);

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
        topicUid: widget.topic.uid!,
      )),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
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
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(dateCreated),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Termin',
                        style: Theme.of(context).textTheme.titleSmall,
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
                                    Color.fromARGB(255, 226, 226, 226),
                                    Colors.white
                                  ])),
                        ),
                        Center(
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.grey[400],
                              value: _isFinished ? 1 : daysLeft / totalDays,
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
                              value: _isFinished ? 1 : hoursLeft / 24,
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
                              value: _isFinished ? 1 : minutesLeft / 60,
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
                                value: _isFinished ? 1 : secondsLeft / 60,
                                strokeWidth: 4.0,
                                color: Colors.green[400]),
                          ),
                        ),
                        Center(
                          child: _isFinished
                              ? const Text('Ukończono')
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
              Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Zadania',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 4,
                    ),
                    _isLoadingTasks
                        ? const SizedBox(
                            height: 50,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : tasks.isEmpty
                            ? const SizedBox(
                                height: 50,
                                child: Center(child: Text('Brak zadań')),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                primary: false,
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    clipBehavior: Clip.hardEdge,
                                    child: Dismissible(
                                      direction: DismissDirection.endToStart,
                                      key: Key(tasks[index].uid!),
                                      dismissThresholds: const {
                                        DismissDirection.endToStart: 0.6
                                      },
                                      onDismissed: (direction) {
                                        _deleteTask(tasks[index]);
                                      },
                                      background: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          alignment: Alignment.centerRight,
                                          decoration: const BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(12),
                                                  bottomRight:
                                                      Radius.circular(12))),
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
                                              widget.topic.uid, tasks[index]);
                                          setState(() {
                                            tasks[index].status = value!;
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
              Card(
                elevation: 4,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Komentarze',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 4,
                      ),
                      StreamBuilder(
                        stream: topicChatStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const SizedBox(
                              height: 50,
                              child: Center(
                                child: Text('Brak komentarzy.'),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return const SizedBox(
                              height: 50,
                              child: Center(
                                child: Text('Coś poszło nie tak...'),
                              ),
                            );
                          }

                          final loadedMessages = snapshot.data!.docs;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: 13,
                              right: 13,
                            ),
                            reverse: true,
                            itemCount: loadedMessages.length,
                            itemBuilder: (context, index) {
                              final TopicComment topicComment =
                                  TopicComment.fromMap(
                                      loadedMessages[index].data());
                              topicComment.uid = loadedMessages[index].id;
                              final chatMessage = loadedMessages[index].data();
                              final TopicComment? nextChatMessage =
                                  index + 1 < loadedMessages.length
                                      ? TopicComment.fromMap(
                                              loadedMessages[index + 1].data())
                                          as TopicComment
                                      : null;

                              final currentMessageUserId =
                                  topicComment.createdBy.uid;
                              final nextMessagesUserId = nextChatMessage != null
                                  ? nextChatMessage.createdBy.uid
                                  : null;
                              final nextUserIsSame =
                                  nextMessagesUserId == currentMessageUserId;
                              return Comment(
                                  topicComment: topicComment,
                                  topicUid: widget.topic.uid!);
                              // if (nextUserIsSame) {
                              //   return Comment.next(
                              //       message: topicComment.text,
                              //       isMe: authenticatedUser.uid ==
                              //           currentMessageUserId);
                              // } else {
                              //   return Comment.first(
                              //       userImage: topicComment.createdBy.imagerUrl,
                              //       username: topicComment.createdBy.username,
                              //       message: topicComment.text,
                              //       isMe: authenticatedUser.uid ==
                              //           currentMessageUserId);
                              // }
                            },
                          );
                        },
                      ),
                    ]),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
