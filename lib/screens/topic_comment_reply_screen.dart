import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stolarczyk_app/providers/db.dart';
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
  Stream<QuerySnapshot<Map<String, dynamic>>>? topicCommentRepliesStream;
  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    topicCommentRepliesStream = DbProvider.topicCommentRepliesStream(
        widget.topicUid, widget.topicComment.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () => Navigator.of(context).pop(true),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Comment(
                    topicComment: widget.topicComment,
                    topicUid: widget.topicUid,
                    commentReply: false,
                    showDivider: true,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 24),
                    decoration: const BoxDecoration(
                        border: Border(
                            left: BorderSide(width: 2, color: Colors.grey))),
                    padding: const EdgeInsets.only(left: 16),
                    child: StreamBuilder(
                      stream: topicCommentRepliesStream,
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
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                        final loadedCommentReplies = snapshot.data!.docs;
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(
                            left: 0,
                            right: 0,
                          ),
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: loadedCommentReplies.length,
                          itemBuilder: (context, index) {
                            final TopicComment topicCommentReply =
                                TopicComment.fromMap(
                                    loadedCommentReplies[index].data());
                            return Comment(
                              topicComment: topicCommentReply,
                              topicUid: widget.topicUid,
                              showDivider: false,
                              commentReply: false,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
