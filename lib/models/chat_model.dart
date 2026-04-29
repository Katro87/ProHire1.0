import 'package:mini_fiverr/models/message_model.dart';

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.meId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.isOtherOnline,
    required this.messages,
  });

  final String id;
  final String meId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final bool isOtherOnline;
  final List<MessageModel> messages;

  String get lastMessage => messages.isEmpty ? '' : messages.last.content;

  DateTime get lastMessageTime {
    if (messages.isEmpty) {
      return DateTime.now();
    }
    return messages.last.timestamp;
  }

  int get unreadCount => messages
      .where((MessageModel m) => !m.isSentByMe && !m.isRead)
      .length;

  bool get hasUnread => unreadCount > 0;

  ConversationModel copyWith({
    List<MessageModel>? messages,
    bool? isOtherOnline,
    String? otherUserName,
    String? otherUserAvatar,
  }) {
    return ConversationModel(
      id: id,
      meId: meId,
      otherUserId: otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      isOtherOnline: isOtherOnline ?? this.isOtherOnline,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'meId': meId,
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserAvatar': otherUserAvatar,
      'isOtherOnline': isOtherOnline,
      'messages': messages.map((MessageModel m) => m.toJson()).toList(),
    };
  }

  factory ConversationModel.fromJson(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] as String,
      meId: map['meId'] as String,
      otherUserId: map['otherUserId'] as String,
      otherUserName: map['otherUserName'] as String,
      otherUserAvatar: map['otherUserAvatar'] as String,
      isOtherOnline: (map['isOtherOnline'] ?? true) as bool,
      messages: (map['messages'] as List<dynamic>)
          .map((dynamic e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
