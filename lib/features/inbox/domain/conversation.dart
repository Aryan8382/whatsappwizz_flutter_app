enum ConversationStatus {
  open('open', 'Open'),
  pending('pending_conv', 'Pending'),
  resolved('resolved', 'Resolved'),
  closed('closed', 'Closed');

  final String value;
  final String label;
  const ConversationStatus(this.value, this.label);

  static ConversationStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'open':
        return ConversationStatus.open;
      case 'pending':
      case 'pending_conv':
        return ConversationStatus.pending;
      case 'resolved':
        return ConversationStatus.resolved;
      case 'closed':
        return ConversationStatus.closed;
      default:
        return ConversationStatus.open;
    }
  }
}

enum WindowUrgency {
  green('Active', '> 4h left'),
  amber('Expiring Soon', '1h - 4h left'),
  red('Urgent', '< 1h left'),
  expired('Expired', 'Send template to re-engage');

  final String title;
  final String description;
  const WindowUrgency(this.title, this.description);
}

/// Matches `conversations` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `conversations` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `contact_id` bigint(20) NOT NULL,
///   `assigned_agent` bigint(20) DEFAULT NULL,
///   `whatsapp_number_id` bigint(20) DEFAULT NULL,
///   `status` varchar(20) NOT NULL DEFAULT 'open',
///   `priority` varchar(20) NOT NULL DEFAULT 'medium',
///   `channel` varchar(50) NOT NULL DEFAULT 'whatsapp',
///   `started_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `closed_at` datetime(3) DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class Conversation {
  final dynamic id;
  final dynamic organizationId;
  final dynamic contactId;
  final dynamic assignedAgent;
  final dynamic whatsappNumberId;
  final ConversationStatus status;
  final String priority;
  final String channel;
  final DateTime startedAt;
  final DateTime? closedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined relations / UI properties
  final String contactName;
  final String contactPhone;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? assignedAgentName;
  final List<String> labels;
  final int unreadCount;
  final DateTime? lastInboundTime;

  const Conversation({
    required this.id,
    this.organizationId = '2',
    this.contactId = '1',
    this.assignedAgent,
    this.whatsappNumberId,
    required this.status,
    this.priority = 'medium',
    this.channel = 'whatsapp',
    DateTime? startedAt,
    this.closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.contactName,
    required this.contactPhone,
    required this.lastMessage,
    required this.lastMessageTime,
    this.assignedAgentName,
    this.labels = const [],
    this.unreadCount = 0,
    this.lastInboundTime,
  })  : startedAt = startedAt ?? lastMessageTime,
        createdAt = createdAt ?? startedAt ?? lastMessageTime,
        updatedAt = updatedAt ?? lastMessageTime;

  Duration get remainingWindow {
    if (lastInboundTime == null) return Duration.zero;
    final expiresAt = lastInboundTime!.add(const Duration(hours: 24));
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Duration? get remainingWindowTime => remainingWindow;

  bool get isWindowExpired => remainingWindow == Duration.zero;

  WindowUrgency get urgency => windowUrgency;

  WindowUrgency get windowUrgency {
    final remaining = remainingWindow;
    if (lastInboundTime == null || remaining == Duration.zero) {
      return WindowUrgency.expired;
    }
    if (remaining.inHours >= 4) {
      return WindowUrgency.green;
    }
    if (remaining.inHours >= 1) {
      return WindowUrgency.amber;
    }
    return WindowUrgency.red;
  }

  DateTime get latestActivityTime {
    if (updatedAt.isAfter(lastMessageTime)) {
      return updatedAt;
    }
    return lastMessageTime;
  }

  DateTime get lastMessageAt => latestActivityTime;


  factory Conversation.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'] != null
        ? ConversationStatus.fromString(json['status'].toString())
        : ConversationStatus.open;

    // Contact info (from nested 'contact' object or direct fields)
    String contactName = 'Unknown';
    String contactPhone = '';
    if (json['contact'] is Map) {
      final c = json['contact'] as Map;
      final fn = c['firstName'] ?? c['first_name'] ?? '';
      final ln = c['lastName'] ?? c['last_name'] ?? '';
      contactName = '$fn $ln'.trim();
      if (contactName.isEmpty) {
        contactName = c['mobile']?.toString() ?? c['phone']?.toString() ?? 'Contact';
      }
      contactPhone = c['mobile']?.toString() ?? c['phone']?.toString() ?? '';
    } else {
      contactName = json['contact_name'] ?? json['contactName'] ?? 'Unknown';
      contactPhone = json['contact_phone'] ?? json['contactPhone'] ?? '';
    }

    // Last message info (from nested 'messages' array or direct fields)
    String lastMsg = '';
    DateTime lastMsgTime = DateTime.now();
    DateTime? lastInbound;
    if (json['messages'] is List && (json['messages'] as List).isNotEmpty) {
      final firstMsg = (json['messages'] as List).first;
      if (firstMsg is Map) {
        lastMsg = firstMsg['messageText'] ??
            firstMsg['message_text'] ??
            firstMsg['body'] ??
            '';
        final rawCreatedAt = firstMsg['createdAt'] ?? firstMsg['created_at'];
        if (rawCreatedAt != null) {
          lastMsgTime = DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now();
        }
        final sType = (firstMsg['senderType'] ?? firstMsg['sender_type'] ?? '').toString().toLowerCase();
        final mType = (firstMsg['messageType'] ?? firstMsg['message_type'] ?? '').toString().toLowerCase();
        if (sType == 'customer' || sType == 'contact' || mType == 'template') {
          lastInbound = lastMsgTime;
        }
      }
    } else {
      lastMsg = json['last_message'] ?? json['lastMessage'] ?? '';
      lastMsgTime = json['last_message_time'] != null
          ? DateTime.tryParse(json['last_message_time'].toString()) ?? DateTime.now()
          : (json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
              : DateTime.now());
    }

    final lastIntRaw = json['contact'] is Map
        ? (json['contact']['lastInteraction'] ?? json['contact']['last_interaction'])
        : null;
    if (lastIntRaw != null) {
      final li = DateTime.tryParse(lastIntRaw.toString());
      if (li != null && (lastInbound == null || li.isAfter(lastInbound))) {
        lastInbound = li;
      }
    }

    // Assigned agent name
    String? agentName;
    if (json['assignedAgent'] is Map) {
      final a = json['assignedAgent'] as Map;
      agentName = '${a['firstName'] ?? ''} ${a['lastName'] ?? ''}'.trim();
    } else {
      agentName = json['assigned_agent_name'] ?? json['assignedAgentName'];
    }
    if (agentName != null && (agentName.trim().isEmpty || agentName.trim().toLowerCase() == 'unassigned')) {
      agentName = null;
    }

    // WhatsApp Number ID
    dynamic wabaNumId = json['whatsapp_number_id'] ?? json['whatsappNumberId'];
    if (wabaNumId == null && json['whatsappNumber'] is Map) {
      wabaNumId = (json['whatsappNumber'] as Map)['id'];
    }

    // Labels
    final rawLabels = json['labels'];
    final List<String> parsedLabels = [];
    if (rawLabels is List) {
      for (final l in rawLabels) {
        if (l is String) {
          parsedLabels.add(l);
        } else if (l is Map) {
          final labelStr = l['name'] ?? l['label'] ?? l['title'];
          if (labelStr != null) parsedLabels.add(labelStr.toString());
        }
      }
    }

    return Conversation(
      id: json['id']?.toString() ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      contactId: json['contact_id'] ?? json['contactId'] ?? '1',
      assignedAgent: json['assigned_agent'] ?? json['assignedAgent'] ?? json['assignedAgentId'],
      whatsappNumberId: wabaNumId,
      status: statusVal,
      priority: json['priority'] ?? 'medium',
      channel: json['channel'] ?? 'whatsapp',
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'].toString()) : null,
      closedAt: json['closed_at'] != null ? DateTime.tryParse(json['closed_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      contactName: contactName,
      contactPhone: contactPhone,
      lastMessage: lastMsg,
      lastMessageTime: lastMsgTime,
      assignedAgentName: agentName,
      labels: parsedLabels,
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
      lastInboundTime: json['last_inbound_time'] != null
          ? DateTime.tryParse(json['last_inbound_time'].toString())
          : (json['lastInboundTime'] != null
              ? DateTime.tryParse(json['lastInboundTime'].toString())
              : lastInbound),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'contact_id': contactId,
      'assigned_agent': assignedAgent,
      'whatsapp_number_id': whatsappNumberId,
      'status': status.value,
      'priority': priority,
      'channel': channel,
      'started_at': startedAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.toIso8601String(),
      'assigned_agent_name': assignedAgentName,
      'labels': labels,
      'unread_count': unreadCount,
      'last_inbound_time': lastInboundTime?.toIso8601String(),
    };
  }

  Conversation copyWith({
    dynamic id,
    dynamic organizationId,
    dynamic contactId,
    dynamic assignedAgent,
    dynamic whatsappNumberId,
    ConversationStatus? status,
    String? priority,
    String? channel,
    DateTime? startedAt,
    DateTime? closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? contactName,
    String? contactPhone,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? assignedAgentName,
    bool clearAssignedAgent = false,
    List<String>? labels,
    int? unreadCount,
    DateTime? lastInboundTime,
  }) {
    return Conversation(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      contactId: contactId ?? this.contactId,
      assignedAgent: clearAssignedAgent ? null : (assignedAgent ?? this.assignedAgent),
      whatsappNumberId: whatsappNumberId ?? this.whatsappNumberId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      channel: channel ?? this.channel,
      startedAt: startedAt ?? this.startedAt,
      closedAt: closedAt ?? this.closedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      assignedAgentName: clearAssignedAgent ? null : (assignedAgentName ?? this.assignedAgentName),
      labels: labels ?? this.labels,
      unreadCount: unreadCount ?? this.unreadCount,
      lastInboundTime: lastInboundTime ?? this.lastInboundTime,
    );
  }
}
