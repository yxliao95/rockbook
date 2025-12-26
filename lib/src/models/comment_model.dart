class CommentReply {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  const CommentReply({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });
}

class CommentEntry {
  final String id;
  final String targetKey;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final List<CommentReply> replies;

  const CommentEntry({
    required this.id,
    required this.targetKey,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.replies = const [],
  });

  CommentEntry copyWith({
    String? id,
    String? targetKey,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    List<CommentReply>? replies,
  }) {
    return CommentEntry(
      id: id ?? this.id,
      targetKey: targetKey ?? this.targetKey,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }
}
