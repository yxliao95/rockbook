import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../provider/comment_provider.dart';
import '../../provider/user_provider.dart';
import 'auth_helpers.dart';

class CommentSection extends ConsumerStatefulWidget {
  final String targetKey;
  final String title;

  const CommentSection({super.key, required this.targetKey, this.title = '评论区'});

  @override
  ConsumerState<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  String? _replyingToId;

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsByTargetProvider(widget.targetKey));
    final currentUser = ref.watch(currentUserProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (comments.isEmpty)
            Text('暂无评论', style: Theme.of(context).textTheme.bodyMedium)
          else
            ...comments.map((comment) => _buildCommentCard(context, comment)),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: '添加评论',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 3,
            enabled: currentUser != null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => _submitComment(context, currentUser),
              child: const Text('发布评论'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(BuildContext context, CommentEntry comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(comment.authorName, style: Theme.of(context).textTheme.titleSmall),
                Text(_formatDateTime(comment.createdAt), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 6),
            Text(comment.content),
            const SizedBox(height: 8),
            if (comment.replies.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comment.replies.map((reply) => _buildReplyRow(context, reply)).toList(),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _startReply(comment.id),
                child: const Text('回复'),
              ),
            ),
            if (_replyingToId == comment.id) _buildReplyInput(context, comment.id),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyRow(BuildContext context, CommentReply reply) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${reply.authorName}：', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 4),
          Expanded(child: Text(reply.content, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildReplyInput(BuildContext context, String commentId) {
    final currentUser = ref.watch(currentUserProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _replyController,
          decoration: const InputDecoration(
            labelText: '回复',
            border: OutlineInputBorder(),
          ),
          minLines: 1,
          maxLines: 2,
          enabled: currentUser != null,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () => _submitReply(context, currentUser, commentId),
            child: const Text('发布回复'),
          ),
        ),
      ],
    );
  }

  void _startReply(String commentId) {
    setState(() {
      _replyingToId = commentId;
      _replyController.clear();
    });
  }

  void _submitComment(BuildContext context, AppUser? user) {
    if (!requireLogin(context, ref)) return;
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    ref.read(commentProvider.notifier).addComment(
          CommentEntry(
            id: 'cmt-${DateTime.now().microsecondsSinceEpoch}',
            targetKey: widget.targetKey,
            authorId: user!.id,
            authorName: user.nickname,
            content: content,
            createdAt: DateTime.now(),
          ),
        );
    _commentController.clear();
  }

  void _submitReply(BuildContext context, AppUser? user, String commentId) {
    if (!requireLogin(context, ref)) return;
    final content = _replyController.text.trim();
    if (content.isEmpty) return;
    ref.read(commentProvider.notifier).addReply(
          commentId: commentId,
          reply: CommentReply(
            id: 'rpl-${DateTime.now().microsecondsSinceEpoch}',
            authorId: user!.id,
            authorName: user.nickname,
            content: content,
            createdAt: DateTime.now(),
          ),
        );
    setState(() {
      _replyController.clear();
      _replyingToId = null;
    });
  }

  String _formatDateTime(DateTime value) {
    final paddedMonth = value.month.toString().padLeft(2, '0');
    final paddedDay = value.day.toString().padLeft(2, '0');
    final paddedHour = value.hour.toString().padLeft(2, '0');
    final paddedMinute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$paddedMonth-$paddedDay $paddedHour:$paddedMinute';
  }
}
