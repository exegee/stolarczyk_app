import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stolarczyk_app/models/appUser.dart';
import 'package:stolarczyk_app/models/task.dart';
import 'package:stolarczyk_app/models/topic_comment.dart';

class Topic {
  String? uid;
  String name;
  String shortDescription;
  String longDescription;
  bool status; // 0 - Started, // 1 - Finished
  List<Task>? tasks;
  List<TopicComment>? comments;
  int commentsCount;
  AppUser createdBy;
  DateTime dateCreated;
  DateTime deadline;
  double progress;
  int priority;
  bool? subscribed;
  int totalTasks;
  int completedTasks;

  Topic(
      {this.uid,
      required this.name,
      required this.shortDescription,
      required this.longDescription,
      required this.status,
      this.tasks,
      required this.commentsCount,
      required this.createdBy,
      required this.dateCreated,
      required this.deadline,
      required this.progress,
      required this.priority,
      this.comments,
      this.subscribed,
      required this.completedTasks,
      required this.totalTasks});

  String get shortName {
    final words = name.split(" ");
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else if (words.length == 2) {
      return words[0][0].toUpperCase() + words[1][0].toUpperCase();
    } else {
      return words[0][0].toUpperCase() +
          words[1][0].toUpperCase() +
          words[2][0].toUpperCase();
    }
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'shortDescription': shortDescription,
        'longDescription': longDescription,
        'status': status,
        'createdBy': createdBy.toMap(),
        'dateCreated': dateCreated,
        'deadline': deadline,
        'progress': progress,
        'priority': priority,
        'commentsCount': commentsCount,
        'completedTasks': completedTasks,
        'totalTasks': totalTasks
      };

  factory Topic.fromMap(Map<String, dynamic> data) {
    return Topic(
      uid: data['uid'],
      name: data['name'],
      shortDescription: data['shortDescription'],
      longDescription: data['longDescription'],
      status: data['status'],
      dateCreated: DateTime.fromMicrosecondsSinceEpoch(
          (data['dateCreated'] as Timestamp).microsecondsSinceEpoch),
      deadline: DateTime.fromMicrosecondsSinceEpoch(
          (data['deadline'] as Timestamp).microsecondsSinceEpoch),
      progress: data['progress'],
      createdBy: AppUser.fromMap(data['createdBy']),
      priority: data['priority'],
      commentsCount: data['commentsCount'],
      completedTasks: data['completedTasks'],
      totalTasks: data['totalTasks'],
    );
  }

  factory Topic.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    // print(data);
    return Topic(
      uid: snapshot.id,
      name: data['name'],
      shortDescription: data['shortDescription'],
      longDescription: data['longDescription'],
      status: data['status'],
      dateCreated: DateTime.fromMicrosecondsSinceEpoch(
          (data['dateCreated'] as Timestamp).microsecondsSinceEpoch),
      deadline: DateTime.fromMicrosecondsSinceEpoch(
          (data['deadline'] as Timestamp).microsecondsSinceEpoch),
      progress: data['progress'],
      createdBy: AppUser.fromMap(data['createdBy']),
      priority: data['priority'],
      commentsCount: data['commentsCount'],
      completedTasks: data['completedTasks'],
      totalTasks: data['totalTasks'],
      // subscribed: data['subscribed'],
      //subscribed: true,
    );
  }
  factory Topic.empty() {
    return Topic(
        name: '',
        shortDescription: '',
        longDescription: '',
        status: false,
        createdBy: AppUser.init(),
        dateCreated: DateTime.now(),
        deadline: DateTime.now(),
        progress: 0.0,
        priority: 0,
        commentsCount: 0,
        completedTasks: 0,
        totalTasks: 0);
  }
}

class TopicNotifier extends StateNotifier<Topic> {
  TopicNotifier() : super(Topic.empty());

  void modifyTopicCommentCount(int value) {
    state.commentsCount = state.commentsCount + value;
  }
}

final topicProvider = StateNotifierProvider<TopicNotifier, Topic>((ref) {
  return TopicNotifier();
});
