import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavDestinationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badgeCount;

  const NavDestinationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
  });
}

/// Double-Glass Floating Bottom Navigation Bar.
/// Two concentric glass layers create depth:
///   Outer shell  — wide blur + very faint white tint + crisp rim border
///   Inner shell  — tighter blur + slightly more opaque tint + inset border
/// Active pill sits inside the inner shell with a solid frosted fill.
class PremiumBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavDestinationItem> items;

  const PremiumBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  });

  @override
  State<PremiumBottomNavBar> createState() => _PremiumBottomNavBarState();
}

class _PremiumBottomNavBarState extends State<PremiumBottomNavBar>
    with SingleTickerProviderStateMixin {
  late double _currentPosition;
  late AnimationController _animController;
  Animation<double>? _slideAnimation;
  bool _isDragging = false;
  int _lastHapticIndex = -1;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.selectedIndex.toDouble();
    _lastHapticIndex = widget.selectedIndex;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void didUpdateWidget(covariant PremiumBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex && !_isDragging) {
      _animateTo(widget.selectedIndex.toDouble());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animateTo(double targetIndex, {VoidCallback? onComplete}) {
    if (_animController.isAnimating) _animController.stop();

    final startPosition = _currentPosition;
    final distance = (targetIndex - startPosition).abs();
    final durationMs = (240 + (distance * 40)).clamp(250, 380).toInt();
    _animController.duration = Duration(milliseconds: durationMs);

    _slideAnimation = Tween<double>(
      begin: startPosition,
      end: targetIndex,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Cubic(0.22, 1.0, 0.36, 1.0),
      ),
    )..addListener(() {
        setState(() => _currentPosition = _slideAnimation!.value);
      });

    _animController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() => _currentPosition = targetIndex);
        onComplete?.call();
      }
    });
  }

  double _applyRubberBand(double rawPos, int maxIndex) {
    if (rawPos < 0.0) return -(-rawPos * 0.22).clamp(0.0, 0.25);
    if (rawPos > maxIndex) {
      return maxIndex + ((rawPos - maxIndex) * 0.22).clamp(0.0, 0.25);
    }
    return rawPos;
  }

  void _handlePanStart(DragStartDetails details, double itemWidth) {
    if (_animController.isAnimating) _animController.stop();
    HapticFeedback.selectionClick();
    setState(() => _isDragging = true);
  }

  void _handlePanUpdate(DragUpdateDetails details, double itemWidth) {
    final rawPos = (details.localPosition.dx - (itemWidth / 2)) / itemWidth;
    final maxIndex = widget.items.length - 1;
    final dampedPos = _applyRubberBand(rawPos, maxIndex);
    final nearest = rawPos.round().clamp(0, maxIndex);
    if (nearest != _lastHapticIndex) {
      HapticFeedback.selectionClick();
      _lastHapticIndex = nearest;
    }
    setState(() => _currentPosition = dampedPos);
  }

  void _handlePanEnd(DragEndDetails details, double itemWidth) {
    setState(() => _isDragging = false);
    final maxIndex = widget.items.length - 1;
    int targetIndex = _currentPosition.round();
    final velocity = details.primaryVelocity ?? 0.0;
    if (velocity.abs() > 300) {
      targetIndex = velocity > 0
          ? (_currentPosition + 0.35).ceil()
          : (_currentPosition - 0.35).floor();
    }
    targetIndex = targetIndex.clamp(0, maxIndex);
    HapticFeedback.lightImpact();
    _lastHapticIndex = targetIndex;
    _animateTo(targetIndex.toDouble(), onComplete: () {
      if (targetIndex != widget.selectedIndex) widget.onItemSelected(targetIndex);
    });
  }

  void _handleTap(int index) {
    if (_isDragging) return;
    HapticFeedback.lightImpact();
    _lastHapticIndex = index;
    _animateTo(index.toDouble(), onComplete: () => widget.onItemSelected(index));
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.items.length;
    if (itemCount == 0) return const SizedBox.shrink();

    return SelectionContainer.disabled(
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: _DoubleGlassShell(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final itemWidth = totalWidth / itemCount;
                // Perfect capsule shape hugging the active icon
                final capsuleWidth = (itemWidth - 12).clamp(38.0, 54.0);
                final capsuleLeft = (_currentPosition * itemWidth) + (itemWidth - capsuleWidth) / 2;
                const capsuleTop = 6.0;
                const capsuleHeight = 30.0;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (d) => _handlePanStart(d, itemWidth),
                  onHorizontalDragUpdate: (d) => _handlePanUpdate(d, itemWidth),
                  onHorizontalDragEnd: (d) => _handlePanEnd(d, itemWidth),
                  onTapUp: (d) {
                    final idx = (d.localPosition.dx / itemWidth)
                        .floor()
                        .clamp(0, itemCount - 1);
                    _handleTap(idx);
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ─── Active Icon Capsule ───
                      Positioned(
                        left: capsuleLeft,
                        top: capsuleTop,
                        width: capsuleWidth,
                        height: capsuleHeight,
                        child: AnimatedScale(
                          scale: _isDragging ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF22C55E), // WhatsApp vibrant emerald
                                  Color(0xFF16A34A), // deep jewel green
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF16A34A).withOpacity(0.38),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                  spreadRadius: -1,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.40),
                                  blurRadius: 1.5,
                                  offset: const Offset(0, -0.8),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height: 3.5,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withOpacity(0.55),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ─── Nav Items ───
                      Positioned.fill(
                        child: Row(
                          children: List.generate(itemCount, (index) {
                            final item = widget.items[index];
                            final dist = (_currentPosition - index).abs();
                            final influenceRadius = _isDragging ? 1.55 : 1.35;
                            double proximity = 0.0;
                            if (dist < influenceRadius) {
                              proximity =
                                  (math.cos((dist / influenceRadius) * math.pi) + 1.0) / 2.0;
                            }
                            final directFactor = (1.0 - dist).clamp(0.0, 1.0);
                            final isActive = directFactor > 0.45;

                            // Icon turns pure crisp white when inside the emerald capsule
                            final iconColor = Color.lerp(
                              const Color(0xFF475569),
                              Colors.white,
                              math.pow(directFactor, 1.4).toDouble(),
                            )!;

                            // Label turns rich emerald green when active
                            final labelColor = Color.lerp(
                              const Color(0xFF64748B),
                              const Color(0xFF15803D),
                              math.pow(proximity, 1.2).toDouble(),
                            )!;

                            final iconScale = 1.0 + ((_isDragging ? 0.12 : 0.08) * proximity);
                            final labelScale = 1.0 + ((_isDragging ? 0.05 : 0.03) * proximity);

                            final fontWeight = FontWeight.lerp(
                              FontWeight.w500,
                              FontWeight.w700,
                              math.pow(proximity, 1.4).toDouble(),
                            )!;

                            final badge = item.badgeCount;
                            final semanticLabel = badge != null && badge > 0
                                ? '${item.label}, $badge notifications'
                                : item.label;

                            return Expanded(
                              child: Semantics(
                                container: true,
                                button: true,
                                selected: isActive,
                                label: semanticLabel,
                                tooltip: item.label,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Fixed 30px height perfectly aligning with the 30px active capsule
                                      SizedBox(
                                        height: 30,
                                        child: Center(
                                          child: Transform.scale(
                                            scale: iconScale,
                                            alignment: Alignment.center,
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(
                                                  directFactor > 0.5
                                                      ? item.activeIcon
                                                      : item.icon,
                                                  size: 19,
                                                  color: iconColor,
                                                ),
                                                if (badge != null && badge > 0)
                                                  Positioned(
                                                    top: -3,
                                                    right: -8,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 1,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEF4444),
                                                        borderRadius: BorderRadius.circular(10),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.18),
                                                            blurRadius: 3,
                                                            offset: const Offset(0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        badge > 99 ? '99+' : '$badge',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 8.5,
                                                          fontWeight: FontWeight.w700,
                                                          height: 1.1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Transform.scale(
                                        scale: labelScale,
                                        alignment: Alignment.center,
                                        child: Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            height: 1.0,
                                            leadingDistribution:
                                                TextLeadingDistribution.even,
                                            fontWeight: fontWeight,
                                            color: labelColor,
                                            letterSpacing: -0.1,
                                            backgroundColor: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Liquid Glass Shell
// Ultra-clean frosted glass capsule with pure downward ambient shadow
// Completely eliminates any upper gray border, seam, or upward shadow bleed.
// ─────────────────────────────────────────────
class _DoubleGlassShell extends StatelessWidget {
  final Widget child;
  const _DoubleGlassShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          // Soft ambient drop shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
          // Subtle brand emerald ambient glow
          BoxShadow(
            color: const Color(0xFF16A34A).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          // Optical background blur for underlying content
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              // Truly transparent luminous glassmorphism
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.24),
                  Colors.white.withOpacity(0.10),
                ],
              ),
              // Frosted rim border — crisp and luminous
              border: Border.all(
                color: Colors.white.withOpacity(0.38),
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
