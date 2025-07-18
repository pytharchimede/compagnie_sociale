enum MessageType {
  text,
  image,
  audio,
  file,
  location
}

class Message {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;
  final String? attachmentUrl;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = false,
    this.attachmentUrl,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      type: MessageType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => MessageType.text,
      ),
      isRead: json['isRead'] ?? false,
      attachmentUrl: json['attachmentUrl'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
      'metadata': metadata,
    };
  }

  Message copyWith({
    String? id,
    String? text,
    String? senderId,
    String? receiverId,
    DateTime? timestamp,
    MessageType? type,
    bool? isRead,
    String? attachmentUrl,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
