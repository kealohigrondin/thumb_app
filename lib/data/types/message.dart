class Message {
  Message({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.isMine,
  });

  final String id;

  final String userId;

  final String content;

  final DateTime createdAt;

  final bool isMine;

  Message.fromJson({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['id'],
        userId = map['user_id'],
        content = map['content'],
        createdAt = DateTime.parse(map['created_at']),
        isMine = myUserId == map['user_id'];
}
