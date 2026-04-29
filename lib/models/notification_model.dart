enum NotificationType {
  message,
  hireAccepted,
  hireDeclined,
  newHireRequest,
  projectCompleted,
  info,
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.previewText,
    this.relatedConversationId,
    this.relatedRequestId,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String? previewText;
  final DateTime timestamp;
  final NotificationType type;
  final String? relatedConversationId;
  final String? relatedRequestId;
  final bool isRead;

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      previewText: previewText,
      timestamp: timestamp,
      type: type,
      relatedConversationId: relatedConversationId,
      relatedRequestId: relatedRequestId,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'previewText': previewText,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'relatedConversationId': relatedConversationId,
      'relatedRequestId': relatedRequestId,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      previewText: json['previewText'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: NotificationType.values.firstWhere(
        (NotificationType t) => t.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      relatedConversationId: json['relatedConversationId'] as String?,
      relatedRequestId: json['relatedRequestId'] as String?,
      isRead: (json['isRead'] ?? false) as bool,
    );
  }
}
