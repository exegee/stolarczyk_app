import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stolarczyk_app/models/appUser.dart';
import 'package:stolarczyk_app/models/topic_comment.dart';

import '../models/task.dart';
import '../models/topic.dart';

class DbProvider {
  static Future<DocumentReference> getAuthenticatedUserRef() async {
    final userRef = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('users').doc(userRef!.uid);
  }

  static Future<AppUser?> getAuthenticatedUser() async {
    final userRef = FirebaseAuth.instance.currentUser;
    AppUser user = await FirebaseFirestore.instance
        .collection('users')
        .doc(userRef!.uid)
        .get()
        .then((value) {
      var data = value.data()!;
      data.addEntries([MapEntry('uid', userRef.uid)]);
      return AppUser.fromMap(data);
    });
    return user;
  }

  static Future<List<Topic>> getTopics() async {
    List<Topic> topics = [];
    await FirebaseFirestore.instance
        .collection('topics')
        .get()
        .then((snapshot) {
      var topicDocs = snapshot.docs;
      for (var topic in topicDocs) {
        topics.add(Topic.fromMap(topic.data()));
      }
    });
    return Future.value(topics);
  }

  static Future<Topic> getTopicByuId(String uid) async {
    Topic topic = Topic.empty();
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(uid)
        .get()
        .then((snapshot) {
      if (snapshot.data()!.isNotEmpty) {
        topic = Topic.fromMap(snapshot.data()!);
      }
    });
    return Future.value(topic);
  }

  static Future<Task> addNewTask(String? topicUid, Task task) async {
    var result = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('tasks')
        .add(task.toMap())
        .then((value) {
      task.uid = value.id;
      return Future.value(task);
    }).catchError((error) {
      return Future.value(task);
    });
    return result;
  }

  static Future<List<Task>> getTopicTasks(String? topicUid) async {
    List<Task> tasks = [];
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('tasks')
        .get()
        .then((snapshot) {
      var topicTasks = snapshot.docs;
      for (var task in topicTasks) {
        var data = task.data();
        data.addEntries([MapEntry('uid', task.reference.id)]);
        tasks.add(Task.fromMap(data));
      }
    });
    return Future.value(tasks);
  }

  static Future<bool> toggleTopicTask(String? topicUid, Task task) async {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('tasks')
        .doc(task.uid)
        .update({'status': !task.status}).then((value) {
      return Future.value(true);
    }).catchError((error) {
      return Future.value(false);
    });
    return Future.value(false);
  }

  static Future<bool> removeTask(String? topicUid, Task task) async {
    var result = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('tasks')
        .doc(task.uid)
        .delete()
        .then((value) {
      return Future.value(true);
    }).onError((error, stackTrace) {
      return Future.value(false);
    });
    return result;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>? topicChatStream(
      String? topicUid) {
    return FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .orderBy('dateCreated', descending: true)
        .snapshots();
  }

  static Future<void> sendTopicComment(
      String topicUid, TopicComment comment) async {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .add(comment.toMap());
  }

  // Sends reply to a comment of the topic
  // topicUid - topic reference uid
  // commentReplyTo - topic comment that we are replying to
  // comment - new comment reply
  static Future<void> sendTopicCommentReply(String topicUid,
      TopicComment commentReplyTo, TopicComment comment) async {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .doc(commentReplyTo.uid)
        .collection('replies')
        .add(comment.toMap());
  }
}
