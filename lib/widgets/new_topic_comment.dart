import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stolarczyk_app/models/topic_comment.dart';
import 'package:stolarczyk_app/providers/db.dart';

import '../models/appUser.dart';

class NewTopicComment extends ConsumerStatefulWidget {
  const NewTopicComment({super.key, required this.topicUid});
  final String topicUid;

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
    AppUser user = ref.watch(appUserProvider);
    FocusScope.of(context).unfocus();
    TopicComment newTopicComment = TopicComment(
        text: enteredMessage, createdBy: user, dateCreated: DateTime.now());
    final DocumentReference userRef =
        await DbProvider.getAuthenticatedUserRef();
    await DbProvider.sendTopicComment(widget.topicUid, newTopicComment);
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
