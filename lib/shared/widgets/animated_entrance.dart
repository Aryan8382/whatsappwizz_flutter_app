import 'package:flutter/material.dart';
import '../../core/theme/app_animations.dart';

// ─── FadeSlideIn ────────────────────────────────────────────────────────────

/// Smoothly fades and slides a child into view on mount.
/// Use [FadeSlideIn.staggered] for list items.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset beginOffset;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = AppAnimations.standard,
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0.0, 0.05),
    this.curve = AppAnimations.enter,
  });

  factory FadeSlideIn.staggered({
    required int index,
    required Widget child,
    Duration duration = AppAnimations.standard,
    Duration baseDelay = const Duration(milliseconds: 42),
    int maxStaggerIndex = 10,
  }) {
    final effectiveIndex = index.clamp(0, maxStaggerIndex);
    return FadeSlideIn(
      delay: baseDelay * effectiveIndex,
      duration: duration,
      child: child,
    );
  }

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ─── ScaleFadeIn ────────────────────────────────────────────────────────────

/// Scales + fades a widget into view. Great for cards and modals.
class ScaleFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double beginScale;
  final Curve curve;

  const ScaleFadeIn({
    super.key,
    required this.child,
    this.duration = AppAnimations.standard,
    this.delay = Duration.zero,
    this.beginScale = 0.92,
    this.curve = AppAnimations.enter,
  });

  factory ScaleFadeIn.staggered({
    required int index,
    required Widget child,
    Duration baseDelay = const Duration(milliseconds: 48),
    int maxStaggerIndex = 8,
  }) {
    final effectiveIndex = index.clamp(0, maxStaggerIndex);
    return ScaleFadeIn(
      delay: baseDelay * effectiveIndex,
      child: child,
    );
  }

  @override
  State<ScaleFadeIn> createState() => _ScaleFadeInState();
}

class _ScaleFadeInState extends State<ScaleFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _scale = Tween<double>(begin: widget.beginScale, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: ScaleTransition(scale: _scale, child: widget.child),
      );
}

// ─── AnimatedPressable ───────────────────────────────────────────────────────

/// Wraps any widget in a press-scale effect for tactile micro-feedback.
class AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final Duration duration;
  final BorderRadius? borderRadius;

  const AnimatedPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.96,
    this.duration = AppAnimations.fast,
    this.borderRadius,
  });

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: widget.scaleDown,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.reverse();
  void _onTapUp(TapUpDetails _) => _ctrl.forward();
  void _onTapCancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}

// ─── AnimatedCounter ────────────────────────────────────────────────────────

/// Rolls a number from its previous value to a new one with a smooth tween.
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  final String suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = AppAnimations.comfortable,
    this.prefix = '',
    this.suffix = '',
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _from = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: widget.value.toDouble())
        .animate(CurvedAnimation(parent: _ctrl, curve: AppAnimations.enter));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _from = old.value;
      _anim = Tween<double>(
        begin: _from.toDouble(),
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(parent: _ctrl, curve: AppAnimations.enter));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => Text(
          '${widget.prefix}${_anim.value.round()}${widget.suffix}',
          style: widget.style,
        ),
      );
}

// ─── AnimatedTabSwitcher ─────────────────────────────────────────────────────

/// Cross-fades between pages when the selected tab index changes.
class AnimatedTabSwitcher extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const AnimatedTabSwitcher({
    super.key,
    required this.index,
    required this.children,
    this.duration = AppAnimations.standard,
  });

  @override
  State<AnimatedTabSwitcher> createState() => _AnimatedTabSwitcherState();
}

class _AnimatedTabSwitcherState extends State<AnimatedTabSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late int _displayIndex;

  @override
  void initState() {
    super.initState();
    _displayIndex = widget.index;
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(AnimatedTabSwitcher old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _ctrl.reverse().then((_) {
        if (mounted) {
          setState(() => _displayIndex = widget.index);
          _ctrl.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: widget.children[_displayIndex.clamp(0, widget.children.length - 1)],
    );
  }
}

// ─── ShimmerLoading ──────────────────────────────────────────────────────────

/// A repeating shimmer gradient for skeleton loading states.
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppAnimations.long,
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-1.5 + _anim.value * 3, 0),
            end: Alignment(-0.5 + _anim.value * 3, 0),
            colors: [
              widget.baseColor,
              widget.highlightColor,
              widget.baseColor,
            ],
          ).createShader(bounds),
          child: widget.child,
        );
      },
    );
  }
}

// ─── PageEntranceWrapper ─────────────────────────────────────────────────────

/// Wraps a full screen in a subtle fade+slide, used in every screen build().
class PageEntranceWrapper extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;

  const PageEntranceWrapper({
    super.key,
    required this.child,
    this.duration = AppAnimations.comfortable,
    this.beginOffset = const Offset(0, 0.025),
  });

  @override
  Widget build(BuildContext context) => FadeSlideIn(
        duration: duration,
        beginOffset: beginOffset,
        child: child,
      );
}
