import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';

enum BotNodeType {
  start('start', 'Start Trigger', LucideIcons.play, Color(0xFF16A34A)),
  message('message', 'Send Message', LucideIcons.messageSquare, Color(0xFF2563EB)),
  question('question', 'Ask Question', LucideIcons.helpCircle, Color(0xFF7C3AED)),
  button('button', 'Interactive Buttons', LucideIcons.mousePointerClick, Color(0xFF0D9488)),
  delay('delay', 'Wait / Delay', LucideIcons.hourglass, Color(0xFFD97706)),
  api('api', 'HTTP / Webhook', LucideIcons.webhook, Color(0xFFDC2626)),
  handover('handover', 'Agent Handover', LucideIcons.headphones, Color(0xFF0891B2)),
  end('end', 'End Flow', LucideIcons.stopCircle, Color(0xFF4B5563));

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const BotNodeType(this.value, this.label, this.icon, this.color);

  static BotNodeType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'start':
        return BotNodeType.start;
      case 'question':
        return BotNodeType.question;
      case 'button':
        return BotNodeType.button;
      case 'delay':
        return BotNodeType.delay;
      case 'api':
        return BotNodeType.api;
      case 'handover':
        return BotNodeType.handover;
      case 'end':
        return BotNodeType.end;
      case 'message':
      default:
        return BotNodeType.message;
    }
  }
}

/// Matches `bot_nodes` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `bot_nodes` (
///   `id` bigint(20) NOT NULL,
///   `flow_id` bigint(20) NOT NULL,
///   `node_type` varchar(50) NOT NULL,
///   `name` varchar(150) DEFAULT NULL,
///   `config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`config`)),
///   `position_x` int(11) NOT NULL DEFAULT 0,
///   `position_y` int(11) NOT NULL DEFAULT 0,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class BotNode {
  final dynamic id;
  final dynamic flowId;
  final String nodeType;
  final String? name;
  final dynamic config;
  final int positionX;
  final int positionY;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // UI helpers
  final BotNodeType type;
  final String title;
  final String content;
  final Offset position;

  const BotNode({
    required this.id,
    this.flowId = '1',
    this.nodeType = 'message',
    this.type = BotNodeType.message,
    this.name,
    this.title = 'Node',
    this.config,
    this.content = '',
    this.positionX = 100,
    this.positionY = 100,
    this.position = const Offset(100, 100),
    this.createdAt,
    this.updatedAt,
  });

  factory BotNode.fromJson(Map<String, dynamic> json) {
    dynamic parsedConfig = json['config'];
    if (parsedConfig is String && parsedConfig.isNotEmpty) {
      try {
        parsedConfig = jsonDecode(parsedConfig);
      } catch (_) {}
    }

    final nType = json['nodeType'] ?? json['node_type'] ?? 'message';
    final parsedType = BotNodeType.fromString(nType.toString());
    final posX = (json['positionX'] as num?)?.toInt() ?? (json['position_x'] as num?)?.toInt() ?? 100;
    final posY = (json['positionY'] as num?)?.toInt() ?? (json['position_y'] as num?)?.toInt() ?? 100;
    final nName = json['name']?.toString() ?? 'Node';
    final contentText = parsedConfig is Map && parsedConfig['text'] != null
        ? parsedConfig['text'].toString()
        : '';

    return BotNode(
      id: json['id']?.toString() ?? '',
      flowId: json['flowId']?.toString() ?? json['flow_id']?.toString() ?? '1',
      nodeType: nType.toString(),
      type: parsedType,
      name: nName,
      title: nName,
      config: parsedConfig,
      content: contentText,
      positionX: posX,
      positionY: posY,
      position: Offset(posX.toDouble(), posY.toDouble()),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flow_id': flowId,
      'node_type': nodeType,
      'name': name,
      'config': config is String ? config : (config != null ? jsonEncode(config) : null),
      'position_x': positionX,
      'position_y': positionY,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  BotNode copyWith({
    dynamic id,
    dynamic flowId,
    String? nodeType,
    BotNodeType? type,
    String? name,
    String? title,
    dynamic config,
    String? content,
    int? positionX,
    int? positionY,
    Offset? position,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BotNode(
      id: id ?? this.id,
      flowId: flowId ?? this.flowId,
      nodeType: nodeType ?? this.nodeType,
      type: type ?? this.type,
      name: name ?? this.name,
      title: title ?? this.title,
      config: config ?? this.config,
      content: content ?? this.content,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Matches `bot_connections` table in `whatsapp_wiz (2).sql`
class BotConnection {
  final dynamic id;
  final dynamic flowId;
  final dynamic sourceNode;
  final dynamic targetNode;
  final String? label;

  const BotConnection({
    this.id = '1',
    this.flowId = '1',
    dynamic sourceNode,
    dynamic targetNode,
    String? fromNodeId,
    String? toNodeId,
    this.label,
  })  : sourceNode = sourceNode ?? fromNodeId ?? '',
        targetNode = targetNode ?? toNodeId ?? '';

  String get fromNodeId => sourceNode.toString();
  String get toNodeId => targetNode.toString();

  factory BotConnection.fromJson(Map<String, dynamic> json) {
    return BotConnection(
      id: json['id']?.toString(),
      flowId: json['flowId']?.toString() ?? json['flow_id']?.toString() ?? '1',
      sourceNode: json['sourceNode']?.toString() ?? json['source_node']?.toString() ?? json['fromNodeId']?.toString(),
      targetNode: json['targetNode']?.toString() ?? json['target_node']?.toString() ?? json['toNodeId']?.toString(),
      label: json['label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flow_id': flowId,
      'source_node': sourceNode,
      'target_node': targetNode,
      'label': label,
    };
  }
}

/// Matches `bot_flows` table in database & website code
class BotFlow {
  final dynamic id;
  final dynamic organizationId;
  final String name;
  final bool published;
  final dynamic createdBy;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final dynamic config;

  // Joined relations / UI properties
  final String description;
  final List<BotNode> nodes;
  final List<BotConnection> connections;

  const BotFlow({
    required this.id,
    this.organizationId = '2',
    required this.name,
    this.published = false,
    bool? isPublished,
    this.createdBy = '2',
    this.createdAt,
    required this.updatedAt,
    this.config,
    this.description = '',
    this.nodes = const [],
    this.connections = const [],
  });

  bool get isPublished => published;

  factory BotFlow.fromJson(Map<String, dynamic> json) {
    dynamic parsedConfig = json['config'];
    if (parsedConfig is String && parsedConfig.isNotEmpty) {
      try {
        parsedConfig = jsonDecode(parsedConfig);
      } catch (_) {}
    }

    final uAt = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
        : (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now());
    final cAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString())
        : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null);

    final rawNodes = json['nodes'];
    List<BotNode> parsedNodes = [];
    if (rawNodes is List) {
      parsedNodes = rawNodes.map((n) => BotNode.fromJson(n as Map<String, dynamic>)).toList();
    }

    final rawConns = json['connections'];
    List<BotConnection> parsedConns = [];
    if (rawConns is List) {
      parsedConns = rawConns.map((c) => BotConnection.fromJson(c as Map<String, dynamic>)).toList();
    }

    return BotFlow(
      id: json['id']?.toString() ?? '',
      organizationId: json['organizationId']?.toString() ?? json['organization_id']?.toString() ?? '2',
      name: json['name']?.toString() ?? '',
      published: json['published'] == 1 || json['published'] == true || json['isPublished'] == true,
      createdBy: json['createdBy']?.toString() ?? json['created_by']?.toString() ?? '2',
      createdAt: cAt,
      updatedAt: uAt,
      config: parsedConfig,
      description: json['description']?.toString() ?? '',
      nodes: parsedNodes,
      connections: parsedConns,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'published': published ? 1 : 0,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'config': config is String ? config : (config != null ? jsonEncode(config) : null),
    };
  }

  BotFlow copyWith({
    dynamic id,
    dynamic organizationId,
    String? name,
    bool? published,
    bool? isPublished,
    dynamic createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic config,
    String? description,
    List<BotNode>? nodes,
    List<BotConnection>? connections,
  }) {
    return BotFlow(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      published: published ?? isPublished ?? this.published,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      config: config ?? this.config,
      description: description ?? this.description,
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Edit form models (matching website frontend/app/(app)/chatbot/page.tsx)
// ──────────────────────────────────────────────────────────────────

class BotButtonForm {
  String id;
  String type; // "QUICK_REPLY" | "URL" | "PHONE_NUMBER" | "LOCATION"
  String text;
  String value;

  BotButtonForm({
    required this.id,
    this.type = 'QUICK_REPLY',
    this.text = '',
    this.value = '',
  });

  factory BotButtonForm.fromJson(Map<String, dynamic> json) {
    return BotButtonForm(
      id: json['id']?.toString() ?? 'btn_${DateTime.now().millisecondsSinceEpoch}',
      type: json['type']?.toString() ?? 'QUICK_REPLY',
      text: json['text']?.toString() ?? '',
      value: json['value']?.toString() ?? json['url']?.toString() ?? json['phone_number']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'text': text,
    'value': value,
  };
}

class BotProductForm {
  String id;
  String name;
  String keywords;
  List<String> images;
  double? price;
  String currency;
  String description;

  BotProductForm({
    required this.id,
    this.name = '',
    this.keywords = '',
    List<String>? images,
    this.price,
    this.currency = '₹',
    this.description = '',
  }) : images = images ?? [];

  factory BotProductForm.fromJson(Map<String, dynamic> json) {
    List<String> imgList = [];
    if (json['images'] is List) {
      imgList = (json['images'] as List).map((i) => i.toString()).toList();
    }
    String kw = '';
    if (json['keywords'] is List) {
      kw = (json['keywords'] as List).join(', ');
    } else if (json['keywords'] != null) {
      kw = json['keywords'].toString();
    }

    return BotProductForm(
      id: json['id']?.toString() ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name']?.toString() ?? '',
      keywords: kw,
      images: imgList,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency']?.toString() ?? '₹',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'keywords': keywords.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
    'images': images.where((img) => img.trim().isNotEmpty).toList(),
    'price': price,
    'currency': currency,
    'description': description,
  };
}

class BotEditForm {
  String project;
  String headerType; // "None" | "Image" | "Video" | "Document"
  String headerMediaUrl;
  String body;
  String footer;
  String messageType; // "Text" | "Image" | "Video" | "Document" | "Audio"
  String greeting;
  List<BotProductForm> products;
  List<BotButtonForm> buttons;

  BotEditForm({
    this.project = '',
    this.headerType = 'None',
    this.headerMediaUrl = '',
    this.body = '',
    this.footer = '',
    this.messageType = 'Text',
    this.greeting = 'Hi! How can I help you today?',
    List<BotProductForm>? products,
    List<BotButtonForm>? buttons,
  })  : products = products ?? [],
        buttons = buttons ?? [];

  static BotEditForm fromFlow(BotFlow flow) {
    Map<String, dynamic> savedConfig = {};
    if (flow.config is Map<String, dynamic>) {
      savedConfig = flow.config as Map<String, dynamic>;
    } else if (flow.config is Map) {
      savedConfig = Map<String, dynamic>.from(flow.config);
    }

    // First message node
    BotNode? firstMsgNode;
    try {
      firstMsgNode = flow.nodes.firstWhere((n) => n.nodeType == 'message');
    } catch (_) {}

    Map<String, dynamic> firstMsgConfig = {};
    if (firstMsgNode?.config is Map) {
      firstMsgConfig = Map<String, dynamic>.from(firstMsgNode!.config);
    }

    final rawProducts = savedConfig['products'] ?? firstMsgConfig['products'];
    List<BotProductForm> loadedProducts = [];
    if (rawProducts is List) {
      loadedProducts = rawProducts.map((p) => BotProductForm.fromJson(p as Map<String, dynamic>)).toList();
    }

    final rawButtons = savedConfig['buttons'] ?? firstMsgConfig['buttons'];
    List<BotButtonForm> loadedButtons = [];
    if (rawButtons is List) {
      loadedButtons = rawButtons.map((b) => BotButtonForm.fromJson(b as Map<String, dynamic>)).toList();
    }

    final bodyText = (firstMsgConfig['text'] ?? savedConfig['greeting'] ?? firstMsgNode?.content ?? 'Hi! How can I help you today?').toString();

    return BotEditForm(
      project: flow.name,
      headerType: (firstMsgConfig['headerType'] ?? savedConfig['headerType'] ?? 'None').toString(),
      headerMediaUrl: (firstMsgConfig['headerMediaUrl'] ?? savedConfig['headerMediaUrl'] ?? '').toString(),
      body: bodyText,
      footer: (firstMsgConfig['footer'] ?? savedConfig['footer'] ?? '').toString(),
      messageType: 'Text',
      greeting: (savedConfig['greeting'] ?? bodyText).toString(),
      products: loadedProducts,
      buttons: loadedButtons,
    );
  }

  Map<String, dynamic> toBotConfig() {
    return {
      'greeting': body.trim().isNotEmpty ? body.trim() : (greeting.trim().isNotEmpty ? greeting.trim() : 'Hi! How can I help you today?'),
      'headerType': headerType,
      'headerMediaUrl': headerType != 'None' ? headerMediaUrl.trim() : '',
      'footer': footer.trim(),
      'products': products.map((p) => p.toJson()).toList(),
      'buttons': buttons.where((b) => b.text.trim().isNotEmpty).map((b) => b.toJson()).toList(),
    };
  }
}
