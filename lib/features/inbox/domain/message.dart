import 'dart:convert';

enum MessageType {
  text,
  image,
  video,
  document,
  audio,
  location,
  template,
  interactive,
  internalNote;

  static MessageType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'document':
        return MessageType.document;
      case 'audio':
        return MessageType.audio;
      case 'location':
        return MessageType.location;
      case 'template':
        return MessageType.template;
      case 'interactive':
        return MessageType.interactive;
      case 'internalnote':
      case 'internal_note':
        return MessageType.internalNote;
      case 'text':
      default:
        return MessageType.text;
    }
  }
}

enum MessageStatus {
  sent,
  delivered,
  read,
  failed;

  static MessageStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      case 'sent':
      default:
        return MessageStatus.sent;
    }
  }
}

enum MessageDirection {
  inbound,
  outbound;

  static MessageDirection fromSenderType(String senderType) {
    final lower = senderType.toLowerCase();
    if (lower == 'contact' || lower == 'user' || lower == 'customer') {
      return MessageDirection.inbound;
    }
    return MessageDirection.outbound;
  }
}

/// Matches `messages` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `messages` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `conversation_id` bigint(20) NOT NULL,
///   `whatsapp_number_id` bigint(20) DEFAULT NULL,
///   `sender_type` varchar(20) NOT NULL,
///   `senderId` bigint(20) DEFAULT NULL,
///   `message_type` varchar(30) NOT NULL DEFAULT 'text',
///   `message_text` longtext DEFAULT NULL,
///   `media_url` text DEFAULT NULL,
///   `meta_message_id` varchar(150) DEFAULT NULL,
///   `status` varchar(30) NOT NULL DEFAULT 'sent',
///   `sent_at` datetime(3) DEFAULT NULL,
///   `delivered_at` datetime(3) DEFAULT NULL,
///   `read_at` datetime(3) DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class Message {
  final dynamic id;
  final dynamic organizationId;
  final dynamic conversationId;
  final dynamic whatsappNumberId;
  final String senderType;
  final dynamic senderId;
  final String messageType;
  final String? messageText;
  final String? mediaUrl;
  final String? metaMessageId;
  final MessageStatus status;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined / UI helper properties
  final MessageDirection direction;
  final MessageType type;
  final String? mediaName;
  final String? mediaSize;
  final String? templateName;
  final List<String> interactiveButtons;
  final bool isInternalNote;

  const Message({
    required this.id,
    this.organizationId = '2',
    required this.conversationId,
    this.whatsappNumberId,
    this.senderType = 'agent',
    this.senderId,
    this.messageType = 'text',
    String? messageText,
    String? body,
    this.mediaUrl,
    this.metaMessageId,
    this.status = MessageStatus.sent,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    required this.createdAt,
    DateTime? updatedAt,
    this.direction = MessageDirection.outbound,
    this.type = MessageType.text,
    this.mediaName,
    this.mediaSize,
    this.templateName,
    this.interactiveButtons = const [],
    this.isInternalNote = false,
  })  : messageText = messageText ?? body ?? '',
        updatedAt = updatedAt ?? createdAt;

  String get body => messageText ?? '';
  DateTime get timestamp => createdAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    final sType = json['sender_type'] ?? json['senderType'] ?? 'agent';
    final mType = json['message_type'] ?? json['messageType'] ?? 'text';
    final statusStr = json['status'] ?? 'sent';
    final cAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
        : (json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now());

    final parsedDir = MessageDirection.fromSenderType(sType.toString());
    final parsedType = MessageType.fromString(mType.toString());

    return Message(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      conversationId: json['conversation_id'] ?? json['conversationId'] ?? '',
      whatsappNumberId: json['whatsapp_number_id'] ?? json['whatsappNumberId'],
      senderType: sType.toString(),
      senderId: json['senderId'] ?? json['sender_id'],
      messageType: mType.toString(),
      messageText: () {
        final raw = (json['messageText'] ?? json['message_text'] ?? json['body'] ?? '').toString();
        if (raw.startsWith('{') && raw.contains('"body"')) {
          try {
            final parsed = jsonDecode(raw);
            if (parsed is Map && parsed['body'] != null) {
              return parsed['body'].toString();
            }
          } catch (_) {}
        }
        return raw;
      }(),
      mediaUrl: json['media_url'] ?? json['mediaUrl'],
      metaMessageId: json['meta_message_id'] ?? json['metaMessageId'],
      status: MessageStatus.fromString(statusStr.toString()),
      sentAt: json['sent_at'] != null ? DateTime.tryParse(json['sent_at'].toString()) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'].toString()) : null,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
      createdAt: cAt,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      direction: parsedDir,
      type: parsedType,
      mediaName: json['media_name'] ?? json['mediaName'],
      mediaSize: json['media_size'] ?? json['mediaSize'],
      templateName: json['template_name'] ?? json['templateName'],
      interactiveButtons: () {
        final raw = json['interactive_buttons'] ?? json['interactiveButtons'];
        if (raw is List) return raw.map((e) => e.toString()).toList();
        if (raw is String && raw.startsWith('[')) {
          try {
            final decoded = jsonDecode(raw);
            if (decoded is List) return decoded.map((e) => e.toString()).toList();
          } catch (_) {}
        }
        return <String>[];
      }(),
      isInternalNote: json['is_internal_note'] == true || sType == 'internal_note',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'conversation_id': conversationId,
      'whatsapp_number_id': whatsappNumberId,
      'sender_type': senderType,
      'senderId': senderId,
      'message_type': messageType,
      'message_text': messageText,
      'media_url': mediaUrl,
      'meta_message_id': metaMessageId,
      'status': status.name,
      'sent_at': sentAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Message copyWith({
    dynamic id,
    dynamic organizationId,
    dynamic conversationId,
    dynamic whatsappNumberId,
    String? senderType,
    dynamic senderId,
    String? messageType,
    String? messageText,
    String? mediaUrl,
    String? metaMessageId,
    MessageStatus? status,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    MessageDirection? direction,
    MessageType? type,
    String? body,
    String? mediaName,
    String? mediaSize,
    String? templateName,
    List<String>? interactiveButtons,
    bool? isInternalNote,
  }) {
    return Message(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      conversationId: conversationId ?? this.conversationId,
      whatsappNumberId: whatsappNumberId ?? this.whatsappNumberId,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      messageType: messageType ?? this.messageType,
      messageText: messageText ?? (body ?? this.messageText),
      mediaUrl: mediaUrl ?? this.mediaUrl,
      metaMessageId: metaMessageId ?? this.metaMessageId,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      direction: direction ?? this.direction,
      type: type ?? this.type,
      mediaName: mediaName ?? this.mediaName,
      mediaSize: mediaSize ?? this.mediaSize,
      templateName: templateName ?? this.templateName,
      interactiveButtons: interactiveButtons ?? this.interactiveButtons,
      isInternalNote: isInternalNote ?? this.isInternalNote,
    );
  }
}
