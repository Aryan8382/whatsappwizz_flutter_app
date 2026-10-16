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

/// Double-Glass Floating Bottom Navigation Bar with True Tactile Depth.
/// Layers:
///   1. Outer Capsule — Optical glassmorphism (sigma 28 blur, specular rim, ambient emerald shadows)
///   2. Active Pill   — Inset 3D frosted ceramic-glass capsule with inner glow and top reflection arc
///   3. Active Icons  — 3D gradient shader mask, ambient backlight halo, tactile drop shadow
///   4. Active Text   — Embossed/engraved dual-layer shadow typography with micro-pip indicator
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _DoubleGlassShell(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final itemWidth = totalWidth / itemCount;
                const pillMarginH = 3.5;
                final pillWidth = itemWidth - (pillMarginH * 2);
                final pillLeft = (_currentPosition * itemWidth) + pillMarginH;

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
                      // ─── 3D Elevated Active Frosted Pill ───
                      Positioned(
                        left: pillLeft,
                        top: 4,
                        bottom: 4,
                        width: pillWidth,
                        child: AnimatedScale(
                          scale: _isDragging ? 1.04 : 1.0,
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                // Ambient emerald soft glow
                                BoxShadow(
                                  color: const Color(0xFF16A34A).withOpacity(0.18),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                  spreadRadius: -1,
                                ),
                                // Pure specular top rim light
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.95),
                                  blurRadius: 1.5,
                                  offset: const Offset(0, -1),
                                  spreadRadius: 0,
                                ),
                                // Soft contact shadow
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(_isDragging ? 0.98 : 0.95),
                                        const Color(0xFFF0FDF4).withOpacity(_isDragging ? 0.94 : 0.88),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFF22C55E).withOpacity(0.28),
                                      width: 1.1,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Soft emerald inner backlight aura
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(22),
                                            gradient: RadialGradient(
                                              center: Alignment.center,
                                              radius: 0.85,
                                              colors: [
                                                const Color(0xFF22C55E).withOpacity(0.12),
                                                const Color(0xFF22C55E).withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Top specular glossy sheen arc
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          height: 8,
                                          margin: const EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white.withOpacity(0.75),
                                                Colors.white.withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ─── Nav Items with 3D Depth ───
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

                            final iconScale = 1.0 + ((_isDragging ? 0.16 : 0.13) * proximity);
                            final labelScale = 1.0 + ((_isDragging ? 0.06 : 0.04) * proximity);
                            final floatLift = -1.5 * proximity;

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
                                  child: Transform.translate(
                                    offset: Offset(0, floatLift),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // ─── Icon with Depth & Lighting ───
                                        Transform.scale(
                                          scale: iconScale,
                                          alignment: Alignment.center,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            alignment: Alignment.center,
                                            children: [
                                              // Ambient Backlight Halo behind active icon
                                              if (proximity > 0.15)
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: RadialGradient(
                                                      colors: [
                                                        const Color(0xFF22C55E)
                                                            .withOpacity(0.20 * proximity),
                                                        const Color(0xFF22C55E)
                                                            .withOpacity(0.0),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                              // Tactile Drop Shadow Layer under Icon
                                              if (proximity > 0.25)
                                                Transform.translate(
                                                  offset: Offset(0, 1.8 * proximity),
                                                  child: Icon(
                                                    item.activeIcon,
                                                    size: 20,
                                                    color: const Color(0xFF15803D)
                                                        .withOpacity(0.25 * proximity),
                                                  ),
                                                ),

                                              // Primary Icon with Light-to-Depth Gradient
                                              ShaderMask(
                                                shaderCallback: (bounds) {
                                                  return LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Color.lerp(
                                                        const Color(0xFF64748B),
                                                        const Color(0xFF22C55E),
                                                        proximity,
                                                      )!,
                                                      Color.lerp(
                                                        const Color(0xFF64748B),
                                                        const Color(0xFF15803D),
                                                        proximity,
                                                      )!,
                                                    ],
                                                  ).createShader(bounds);
                                                },
                                                blendMode: BlendMode.srcIn,
                                                child: Icon(
                                                  directFactor > 0.5
                                                      ? item.activeIcon
                                                      : item.icon,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                              ),

                                              // Badge
                                              if (badge != null && badge > 0)
                                                Positioned(
                                                  top: -4,
                                                  right: -10,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 4.5,
                                                      vertical: 1,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF1E293B),
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Colors.white.withOpacity(0.4),
                                                        width: 0.8,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.18),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 1),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      badge > 99 ? '99+' : '$badge',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.w700,
                                                        height: 1.1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 2.5),

                                        // ─── Text Label with Embossed Depth Shadows ───
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
                                              color: Color.lerp(
                                                const Color(0xFF64748B),
                                                const Color(0xFF15803D),
                                                proximity,
                                              ),
                                              letterSpacing: -0.15,
                                              backgroundColor: Colors.transparent,
                                              shadows: [
                                                // Top specular deboss highlight
                                                Shadow(
                                                  color: Colors.white.withOpacity(0.9 * proximity),
                                                  offset: const Offset(0, 0.8),
                                                  blurRadius: 0.5,
                                                ),
                                                // Ambient depth shadow
                                                Shadow(
                                                  color: const Color(0xFF16A34A).withOpacity(0.28 * proximity),
                                                  offset: const Offset(0, 1.2),
                                                  blurRadius: 2.5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // ─── Active Pip Indicator (tactile feedback dot) ───
                                        const SizedBox(height: 2),
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          width: 12 * proximity,
                                          height: 2.2,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(2),
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF22C55E).withOpacity(0.9 * proximity),
                                                const Color(0xFF15803D).withOpacity(0.9 * proximity),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF22C55E).withOpacity(0.4 * proximity),
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
// Multi-layer frosted glass capsule with realistic optical refraction,
// specular top highlight, and multi-tier ambient emerald drop shadow.
// ─────────────────────────────────────────────
class _DoubleGlassShell extends StatelessWidget {
  final Widget child;
  const _DoubleGlassShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          // Ambient Emerald Glow (brand luminescence)
          BoxShadow(
            color: const Color(0xFF16A34A).withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          // Deep Soft Ambient Drop Shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          // Specular Top Rim Reflection
          BoxShadow(
            color: Colors.white.withOpacity(0.95),
            blurRadius: 2,
            offset: const Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              // Frosted multi-stop glass gradient
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.94),
                  Colors.white.withOpacity(0.80),
                  Colors.white.withOpacity(0.88),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              // Crisp specular glass border
              border: Border.all(
                color: Colors.white.withOpacity(0.95),
                width: 1.2,
              ),
            ),
            child: Stack(
              children: [
                // Internal top hairline specular shine
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 1.0,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.9),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
