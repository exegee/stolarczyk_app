import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stolarczyk_app/models/appUser.dart';

class TopicComment {
  String? uid;
  String text;
  List<TopicComment>? comments;
  AppUser createdBy;
  DateTime dateCreated;

  TopicComment({
    this.uid,
    required this.text,
    required this.createdBy,
    this.comments,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() => {
        'text': text,
        'createdBy': createdBy.toMap(),
        'dateCreated': dateCreated,
      };
  factory TopicComment.fromMap(Map<String, dynamic> data) {
    return TopicComment(
      uid: data['uid'],
      text: data['text'],
      createdBy: AppUser.fromMap(data['createdBy']),
      dateCreated: DateTime.fromMicrosecondsSinceEpoch(
          (data['dateCreated'] as Timestamp).microsecondsSinceEpoch),
    );
  }

  factory TopicComment.init() {
    return TopicComment(
        createdBy: AppUser.init(),
        dateCreated: DateTime.now(),
        text: '',
        comments: []);
  }
}
