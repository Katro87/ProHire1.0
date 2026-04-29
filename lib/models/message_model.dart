class MessageModel {
  const MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isSentByMe,
    this.isRead = false,
  });

  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isSentByMe;
  final bool isRead;

  MessageModel copyWith({bool? isRead}) {
    return MessageModel(
      id: id,
      senderId: senderId,
      content: content,
      timestamp: timestamp,
      isSentByMe: isSentByMe,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isSentByMe': isSentByMe,
      'isRead': isRead,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isSentByMe: (map['isSentByMe'] ?? false) as bool,
      isRead: (map['isRead'] ?? false) as bool,
    );
  }
}
