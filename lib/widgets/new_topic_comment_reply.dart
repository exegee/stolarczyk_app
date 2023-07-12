import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stolarczyk_app/models/topic_comment.dart';
import 'package:stolarczyk_app/providers/db.dart';

import '../models/appUser.dart';

class NewTopicCommentReply extends ConsumerStatefulWidget {
  const NewTopicCommentReply({
    super.key,
    required this.topicUid,
    required this.commentReplyTo,
  });
  final String topicUid;
  final TopicComment commentReplyTo;

  @override
  ConsumerState<NewTopicCommentReply> createState() => _NewTopicCommentState();
}

// Controller for new topic comment
class _NewTopicCommentState extends ConsumerState<NewTopicCommentReply> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Send new comment for this topic
  void _submitMessage() async {
    final enteredMessage = _commentController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    // Get current user from appUserProvider (Riverpod)
    AppUser user = ref.watch(appUserProvider);
    FocusScope.of(context).unfocus();
    // Create new comment for this topic
    TopicComment newTopicComment = TopicComment(
        text: enteredMessage, createdBy: user, dateCreated: DateTime.now());
    // Send new comment to firebase
    await DbProvider.sendTopicCommentReply(
        widget.topicUid, widget.commentReplyTo, newTopicComment);
    // Clear comment text field
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: const InputDecoration(labelText: 'Co masz na myśli?'),
          ),
        ),
        IconButton(
          onPressed: _submitMessage,
          icon: const Icon(Icons.send),
          color: Theme.of(context).colorScheme.primary,
        )
      ]),
    );
  }
}
