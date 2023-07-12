import 'package:cloud_firestore/cloud_firestore.dart';
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
  AppUser createdBy;
  DateTime dateCreated;
  DateTime deadline;
  double progress;
  int priority;

  Topic(
      {this.uid,
      required this.name,
      required this.shortDescription,
      required this.longDescription,
      required this.status,
      this.tasks,
      required this.createdBy,
      required this.dateCreated,
      required this.deadline,
      required this.progress,
      required this.priority});

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
      };

  factory Topic.fromMap(Map<String, dynamic> data) {
    // bool status =
    // return Topic(
    //     name: data['name'],
    //     shortDescription: data['shortDescription'],
    //     longDescription: data['longDescription'],
    //     status: data['status'],
    //     createdByRef: data['createdByRef'],
    //     dateCreated: DateTime.fromMicrosecondsSinceEpoch(
    //         (data['dateCreated'] as Timestamp).seconds),
    //     deadline: DateTime.fromMicrosecondsSinceEpoch(
    //         (data['deadline'] as Timestamp).seconds),
    //     progress: data['progress'],
    //     priority: data['priority']);
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
    );
  }

  factory Topic.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    //DocumentReference userRef = data['createdByRef'];
    // AppUser user = userRef.get().then((value) {
    //   return AppUser.fromMap(value.data());
    // });
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
        priority: 0);
  }
}
