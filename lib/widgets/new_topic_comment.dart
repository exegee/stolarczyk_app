import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stolarczyk_app/models/topic.dart';
import 'package:stolarczyk_app/models/topic_comment.dart';
import 'package:stolarczyk_app/providers/db.dart';

import '../models/appUser.dart';

class NewTopicComment extends ConsumerStatefulWidget {
  const NewTopicComment(
      {super.key, required this.topicUid, this.onNewCommentSend});
  final String topicUid;
  final VoidCallback? onNewCommentSend;

  @override
  ConsumerState<NewTopicComment> createState() => _NewTopicCommentState();
}

class _NewTopicCommentState extends ConsumerState<NewTopicComment> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _commentController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    // Get current user from appUserProvider
    AppUser? user = await DbProvider.getAuthenticatedUser();
    ref.read(topicProvider.notifier).modifyTopicCommentCount(1);
    // FocusScope.of(context).unfocus();
    TopicComment newTopicComment = TopicComment(
        text: enteredMessage, createdBy: user!, dateCreated: DateTime.now());
    await DbProvider.sendTopicComment(widget.topicUid, newTopicComment);
    widget.onNewCommentSend!.call();
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
      child: TextField(
        controller: _commentController,
        textCapitalization: TextCapitalization.sentences,
        autocorrect: true,
        enableSuggestions: true,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 10),
            labelText: 'Co masz na myśli?',
            suffixIcon: IconButton(
              onPressed: _submitMessage,
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
            )),
      ),
    );
  }
}
