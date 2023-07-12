import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stolarczyk_app/models/topic_comment.dart';
import 'package:stolarczyk_app/screens/topic_comment_reply_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comment extends StatelessWidget {
  const Comment(
      {super.key, required this.topicComment, required this.topicUid});

  final TopicComment topicComment;
  final String topicUid;

  @override
  Widget build(BuildContext context) {
    print(topicComment.uid);
    final String dateAgo =
        timeago.format(topicComment.dateCreated, locale: 'pl');
    final String topicHour =
        DateFormat('hh:mm', 'pl_PL').format(topicComment.dateCreated);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  maxRadius: 18,
                  backgroundImage: NetworkImage(
                    topicComment.createdBy.imagerUrl,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topicComment.createdBy.username,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Text(
                        dateAgo,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.grey[600]),
                      ),
                      Text(
                        ', $topicHour',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.grey[600]),
                      )
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                      iconSize: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Text(topicComment.text),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, TopicCommentReply.routeName,
                      arguments: {
                        'topicComment': topicComment,
                        'topicUid': topicUid
                      });
                },
                icon: const Icon(
                  Icons.reply,
                  size: 18,
                ),
                label: const Text('Odpowiedz'),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              )
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
