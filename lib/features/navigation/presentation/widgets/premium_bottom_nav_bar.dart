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
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _MacOsDockShell(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final itemWidth = totalWidth / itemCount;
                    // Active pill covering both icon and text label
                    const pillMarginH = 3.0;
                    final tileWidth = itemWidth - (pillMarginH * 2);
                    final tileLeft = (_currentPosition * itemWidth) + pillMarginH;

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
                          // ─── Active Pill Covering Both Icon & Label ───
                          Positioned(
                            left: tileLeft,
                            top: 4.5,
                            bottom: 4.5,
                            width: tileWidth,
                            child: AnimatedScale(
                              scale: _isDragging ? 1.04 : 1.0,
                              duration: const Duration(milliseconds: 160),
                              curve: Curves.easeOutCubic,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      // Transparent luminous glass body with soft emerald sheen
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.65),
                                          const Color(0xFFDCFCE7).withOpacity(0.35),
                                          Colors.white.withOpacity(0.25),
                                        ],
                                        stops: const [0.0, 0.45, 1.0],
                                      ),
                                      // Crisp inner specular highlight border
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.90),
                                        width: 1.1,
                                      ),
                                      boxShadow: [
                                        // Outside soft emerald ambient glow
                                        BoxShadow(
                                          color: const Color(0xFF16A34A).withOpacity(0.20),
                                          blurRadius: 12,
                                          offset: const Offset(0, 3.5),
                                          spreadRadius: -1,
                                        ),
                                        // Outside soft neutral drop
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                        // Outside top specular reflection
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.85),
                                          blurRadius: 2,
                                          offset: const Offset(0, -1),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // ── Inside Top Highlight (Specular Glint) ──
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: Container(
                                            height: 1.5,
                                            margin: const EdgeInsets.symmetric(horizontal: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(1),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.0),
                                                  Colors.white.withOpacity(0.95),
                                                  Colors.white.withOpacity(0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // ── Inside Bottom Soft Emerald Glow ──
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 1.0,
                                            margin: const EdgeInsets.symmetric(horizontal: 12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.transparent,
                                                  const Color(0xFF16A34A).withOpacity(0.25),
                                                  Colors.transparent,
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

                            // Classic macOS active indicator and colors
                            final iconColor = Color.lerp(
                              const Color(0xFF64748B),
                              const Color(0xFF16A34A),
                              math.pow(directFactor, 1.2).toDouble(),
                            )!;

                            final labelColor = Color.lerp(
                              const Color(0xFF64748B),
                              const Color(0xFF15803D),
                              math.pow(proximity, 1.2).toDouble(),
                            )!;

                            final iconScale = 1.0 + ((_isDragging ? 0.14 : 0.08) * proximity);
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
                                      Transform.scale(
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
                                              size: 20,
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
                                      const SizedBox(height: 3),
                                      Transform.scale(
                                        scale: labelScale,
                                        alignment: Alignment.center,
                                        child: Text(
                                          item.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 9.5,
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
    ),
  ),
);
  }
}

// ─────────────────────────────────────────────
// macOS Translucent Glass Dock Shell
// Floating centered rounded glass dock with frosted blur and ambient elevation
// ─────────────────────────────────────────────
class _MacOsDockShell extends StatelessWidget {
  final Widget child;
  const _MacOsDockShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          // Soft ambient drop shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 22,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          // Subtle inner depth
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          // Specular top rim highlight
          BoxShadow(
            color: Colors.white.withOpacity(0.85),
            blurRadius: 1,
            offset: const Offset(0, -0.5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          // Optical background blur
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              // macOS frosted translucent glass
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.72),
                  Colors.white.withOpacity(0.52),
                ],
              ),
              // Crisp macOS hairline border
              border: Border.all(
                color: Colors.white.withOpacity(0.80),
                width: 0.85,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
