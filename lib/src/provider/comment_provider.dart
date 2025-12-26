import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comment_model.dart';

class CommentNotifier extends Notifier<List<CommentEntry>> {
  @override
  List<CommentEntry> build() => _seedComments();

  void addComment(CommentEntry entry) {
    state = [...state, entry];
  }

  void addReply({required String commentId, required CommentReply reply}) {
    final next = state.map((comment) {
      if (comment.id != commentId) return comment;
      return comment.copyWith(replies: [...comment.replies, reply]);
    }).toList();
    state = next;
  }

  List<CommentEntry> _seedComments() {
    final now = DateTime.now();
    return [
      CommentEntry(
        id: 'cmt1',
        targetKey: 'page:crags:root',
        authorId: 'u3',
        authorName: '石头',
        content: '华东区域信息很齐全，期待更多线路图。',
        createdAt: now.subtract(const Duration(hours: 3)),
        replies: [
          CommentReply(
            id: 'cmt1-r1',
            authorId: 'u1',
            authorName: '阿岩',
            content: '正在整理更多路线图，稍后补齐。',
            createdAt: now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      CommentEntry(
        id: 'cmt2',
        targetKey: 'page:routes',
        authorId: 'u2',
        authorName: '木木',
        content: '希望能增加线路保护点信息。',
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
    ];
  }
}

final commentProvider = NotifierProvider<CommentNotifier, List<CommentEntry>>(CommentNotifier.new);

final commentsByTargetProvider = Provider.family<List<CommentEntry>, String>((ref, targetKey) {
  return ref.watch(commentProvider).where((comment) => comment.targetKey == targetKey).toList();
});
