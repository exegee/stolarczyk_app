import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stolarczyk_app/models/appUser.dart';
import 'package:stolarczyk_app/models/subscription.dart';
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

  // Add user subsctiption record
  static Future<void> addUserSubscription(String subId, String userId) async {
    // Create subsctiption record
    final subscription = Subscription(userId: userId, topicId: subId);
    // Check if such a subscription exists in db by counting records
    // This value should be no greater than 1
    var sub = await FirebaseFirestore.instance
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .where('topicId', isEqualTo: subId)
        .count()
        .get();
    // If record count is greater than 0 then return
    if (sub.count > 0) {
      return;
    } else {
      // Else add subscription record
      await FirebaseFirestore.instance
          .collection('subscriptions')
          .add(subscription.toMap());
    }
  }

  static Future<bool> deleteUserSubscription(String subId) async {
    return await FirebaseFirestore.instance
        .collection('subscriptions')
        .doc(subId)
        .delete()
        .then((value) {
      return true;
    }).onError((error, stackTrace) {
      return false;
    });
  }

  static Future<List<Subscription>> getUserSubsctiptions(String userId) async {
    return await FirebaseFirestore.instance
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .get()
        .then((snapshot) {
      return snapshot.docs.map((docSnapshot) {
        var sub = Subscription.fromMap(docSnapshot.data());
        sub.id = docSnapshot.id;
        return sub;
      }).toList();
    });
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

  // Delete selected topic
  static Future<bool> removeTopic(Topic topic) async {
    var user = await getAuthenticatedUser();
    var userSubs = await getUserSubsctiptions(user!.uid!);
    if (userSubs.isNotEmpty) {
      var subToDelete =
          userSubs.where((element) => element.topicId == topic.uid).single;
      await deleteUserSubscription(subToDelete.id!);
    }

    var result = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topic.uid)
        .delete()
        .then((value) async {
      return Future.value(true);
    }).onError((error, stackTrace) {
      return Future.value(false);
    });
    return result;
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

  // Removes selected task from topic
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

  // Remove selected topic comment - only by the owner
  static Future<int> removeTopicComment(
      String topicUid, TopicComment topic) async {
    // Get all comments reply
    var replies = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .doc(topic.uid)
        .collection('replies')
        .get();

    // Get replies count and decrease the counter of total comments count on that topic
    final repliesCount = replies.docs.length;
    await decrementTopicCommentsCount(topicUid, repliesCount + 1);

    // Delete every reply of that comment
    for (var reply in replies.docs) {
      await FirebaseFirestore.instance
          .collection('topics')
          .doc(topicUid)
          .collection('comments')
          .doc(topic.uid)
          .collection('replies')
          .doc(reply.id)
          .delete();
    }

    //Delete main comment
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .doc(topic.uid)
        .delete()
        .then((value) {
      return Future.value(true);
    }).onError((error, stackTrace) {
      return Future.value(false);
    });

    return repliesCount + 1;
  }

  // Gets topic comment stream
  static Stream<QuerySnapshot<Map<String, dynamic>>>? topicCommentStream(
      String? topicUid) {
    return FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .orderBy('dateCreated', descending: true)
        .snapshots();
  }

  // Gets topic comment replies stream
  static Stream<QuerySnapshot<Map<String, dynamic>>>? topicCommentRepliesStream(
      String? topicUid, String? commentUid) {
    return FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .doc(commentUid)
        .collection('replies')
        .orderBy('dateCreated', descending: true)
        .snapshots();
  }

  // Sends topic comment
  // topicUid - topic reference uid
  // comment - new comment reply
  static Future<void> sendTopicComment(
      String topicUid, TopicComment comment) async {
    incrementTopicCommentsCount(topicUid);
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
    incrementTopicCommentsCount(topicUid);
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .doc(commentReplyTo.uid)
        .collection('replies')
        .add(comment.toMap());
  }

  // Increments topic comments count by 1
  static Future<void> incrementTopicCommentsCount(String topicUid) async {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .update({'commentsCount': FieldValue.increment(1)});
  }

  // Decrements topic comments count by a number of deleted comments
  static Future<void> decrementTopicCommentsCount(
      String topicUid, int value) async {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .update({'commentsCount': FieldValue.increment(-value)});
  }

  static Future<void> incrementTotalTasksCount(String topicUid) async {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .update({'totalTasks': FieldValue.increment(1)});
  }

  static Future<void> decrementTotalTasksCount(String topicUid) async {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .update({'totalTasks': FieldValue.increment(-1)});
  }

  static Future<int> getTopicsCount() async {
    return await FirebaseFirestore.instance
        .collection('topics')
        .count()
        .get()
        .then((result) {
      return result.count;
    });
  }

  // static Future<List<double>> getTopicsStatistics() async {
  //   return await FirebaseFirestore.instance
  //       .collection('statistics')
  //       .get()
  //       .then((value) {
  //     var docs = value.docs;
  //     docs
  //   });
  // }

  static Future<void> incrementCompletedTasksCount(String topicUid) async {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .update({'completedTasks': FieldValue.increment(1)});
  }

  static Future<void> decrementCompletedTasksCount(String topicUid) async {
    await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .update({'completedTasks': FieldValue.increment(-1)});
  }

  // Gets topic comment count
  static Future<int> getTopicCommentCount(String? topicUid) async {
    var result = await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .count()
        .get()
        .then((value) => value.count);
    return result;
  }

  // Gets latest topic comment reply
  static Future<TopicComment?> getLatestTopicCommentReply(
      String? topicUid, String? commentUid) async {
    return await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .doc(commentUid)
        .collection('replies')
        .orderBy('dateCreated', descending: true)
        .get()
        .then((value) {
      TopicComment? firstCommentReply;
      if (value.docs.isNotEmpty) {
        firstCommentReply = TopicComment.fromMap(value.docs.first.data());
      }
      return firstCommentReply;
    });
  }

  // Get topic comment reply count
  static Future<int> getTopicCommentReplyCount(
      String? topicUid, String? commentUid) async {
    return await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('comments')
        .doc(commentUid)
        .collection('replies')
        .count()
        .get()
        .then((value) => value.count);
  }

  // Get topic tasks count
  static Future<int> getTopicTaskCount(String? topicUid) async {
    return await FirebaseFirestore.instance
        .collection('topics')
        .doc(topicUid)
        .collection('tasks')
        .count()
        .get()
        .then((value) => value.count);
  }

  // static Future<int> getTopicCommentCount(String topicUid) async {
  //   await FirebaseFirestore.instance.collectionGroup(collectionPath)
  // }
}
