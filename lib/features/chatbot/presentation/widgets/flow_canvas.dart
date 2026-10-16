import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../domain/bot_node.dart';

class FlowCanvas extends StatelessWidget {
  final BotFlow flow;
  final ValueChanged<BotNode> onNodeTap;

  const FlowCanvas({
    super.key,
    required this.flow,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9), // Slate background with grid
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(500),
        minScale: 0.3,
        maxScale: 2.5,
        constrained: false,
        child: SizedBox(
          width: 1400,
          height: 1000,
          child: CustomPaint(
            painter: _ConnectionPainter(
              nodes: flow.nodes,
              connections: flow.connections,
            ),
            child: Stack(
              children: flow.nodes.map((node) {
                return Positioned(
                  left: node.position.dx,
                  top: node.position.dy,
                  child: GestureDetector(
                    onTap: () => onNodeTap(node),
                    child: _NodeCard(node: node),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  final BotNode node;

  const _NodeCard({required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: node.type.color.withOpacity(0.5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: node.type.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(node.type.icon, size: 14, color: node.type.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  node.type.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: node.type.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            node.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            node.content,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ConnectionPainter extends CustomPainter {
  final List<BotNode> nodes;
  final List<BotConnection> connections;

  _ConnectionPainter({required this.nodes, required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle background dot grid
    final gridPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.5;

    for (double x = 0; x < size.width; x += 30) {
      for (double y = 0; y < size.height; y += 30) {
        canvas.drawCircle(Offset(x, y), 1.0, gridPaint);
      }
    }

    // 2. Draw Bezier connection paths between nodes
    final linePaint = Paint()
      ..color = AppColors.g600
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final nodeMap = {for (var n in nodes) n.id: n};

    for (final conn in connections) {
      final from = nodeMap[conn.fromNodeId];
      final to = nodeMap[conn.toNodeId];
      if (from == null || to == null) continue;

      // Start from right center of fromNode, connect to left center of toNode
      final p1 = Offset(from.position.dx + 200, from.position.dy + 45);
      final p2 = Offset(to.position.dx, to.position.dy + 45);

      final path = Path();
      path.moveTo(p1.dx, p1.dy);
      final dx = (p2.dx - p1.dx) / 2;
      path.cubicTo(p1.dx + dx, p1.dy, p2.dx - dx, p2.dy, p2.dx, p2.dy);

      canvas.drawPath(path, linePaint);

      // Draw arrow head at destination
      final arrowPaint = Paint()
        ..color = AppColors.g700
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p2, 4.0, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) => true;
}
