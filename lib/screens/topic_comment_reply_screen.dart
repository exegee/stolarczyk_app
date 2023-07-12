import 'package:flutter/material.dart';
import 'package:stolarczyk_app/widgets/comment.dart';

import '../models/topic_comment.dart';
import '../widgets/new_topic_comment_reply.dart';

class TopicCommentReply extends StatefulWidget {
  const TopicCommentReply(
      {super.key, required this.topicComment, required this.topicUid});
  static const routeName = '/topic-comment-reply';
  final TopicComment topicComment;
  final String topicUid;

  @override
  State<TopicCommentReply> createState() => _TopicCommentReplyState();
}

class _TopicCommentReplyState extends State<TopicCommentReply> {
  @override
  void initState() {
    print(widget.topicComment.uid);
    print(widget.topicUid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ), // Display new comment for this topic
        bottomNavigationBar: BottomAppBar(
            child: NewTopicCommentReply(
          topicUid: widget.topicUid,
          commentReplyTo: widget.topicComment,
        )),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Comment(
                topicComment: widget.topicComment, topicUid: widget.topicUid),
          ),
        ));
  }
}
