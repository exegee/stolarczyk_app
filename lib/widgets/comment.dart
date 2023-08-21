import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stolarczyk_app/models/appUser.dart';
import 'package:stolarczyk_app/models/topic_comment.dart';
import 'package:stolarczyk_app/providers/db.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comment extends ConsumerWidget {
  const Comment({
    super.key,
    required this.topicComment,
    required this.topicUid,
    required this.commentReply,
    required this.showDivider,
    this.onDeleteComment,
  });

  final TopicComment topicComment;
  final String topicUid;
  final bool commentReply;
  final bool showDivider;
  final ValueChanged<int>? onDeleteComment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider);
    final canDeleteComment = user.uid == topicComment.createdBy.uid;
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
                    // Dorobic usuwanie odpowiedzi!!! wykorzystac topicocmmentreply
                    canDeleteComment
                        ? PopupMenuButton(
                            surfaceTintColor: Colors.grey,
                            itemBuilder: (_) => [
                                  PopupMenuItem(
                                    child: const Text('Usuń'),
                                    onTap: () async {
                                      await DbProvider.removeTopicComment(
                                              topicUid, topicComment)
                                          .then((value) {
                                        print(value);
                                        onDeleteComment!(value);
                                      });
                                    },
                                  )
                                ])
                        : const SizedBox()
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Text(topicComment.text),
        ],
      ),
    );
  }
}
