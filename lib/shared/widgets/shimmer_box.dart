import 'package:flutter/material.dart';

/// Provides a single synchronized [AnimationController] for all child [ShimmerBox] widgets.
class ShimmerScope extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerScope({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  static double of(BuildContext context) {
    final _ShimmerScopeInherited? inherited =
        context.dependOnInheritedWidgetOfExactType<_ShimmerScopeInherited>();
    return inherited?.progress ?? 0.0;
  }

  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();
}

class _ShimmerScopeState extends State<ShimmerScope> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return _ShimmerScopeInherited(
          progress: _controller.value,
          child: widget.child,
        );
      },
    );
  }
}

class _ShimmerScopeInherited extends InheritedWidget {
  final double progress;

  const _ShimmerScopeInherited({
    required this.progress,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ShimmerScopeInherited oldWidget) {
    return oldWidget.progress != progress;
  }
}

/// A smooth, diagonal shimmering placeholder block.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  const ShimmerBox.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        shape = BoxShape.circle,
        borderRadius = null;

  @override
  Widget build(BuildContext context) {
    final progress = ShimmerScope.of(context);
    final isCircle = shape == BoxShape.circle;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: isCircle ? null : (borderRadius ?? BorderRadius.circular(6)),
        gradient: LinearGradient(
          begin: Alignment(-1.8 + 3.6 * progress, -0.3),
          end: Alignment(-0.2 + 3.6 * progress, 0.3),
          colors: const [
            Color(0xFFEAEFF0),
            Color(0xFFF8FAFB),
            Color(0xFFEAEFF0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
