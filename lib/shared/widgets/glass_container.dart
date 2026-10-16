import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/theme/app_radii.dart';

/// Reusable Liquid Glass Container with BackdropFilter blur,
/// frosted translucency, specular rim highlights, and graceful clipping.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = GlassTokens.blurLg,
    this.borderRadius,
    this.color,
    this.gradient,
    this.border,
    this.boxShadow,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadii.border2xl;

    Widget content = Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (gradient == null ? GlassTokens.frostedLight : null),
        gradient: gradient ?? (color == null ? GlassTokens.cardGlassGradient : null),
        borderRadius: effectiveRadius,
        border: border ??
            Border.all(
              color: GlassTokens.borderSubtle,
              width: 1.1,
            ),
      ),
      child: child,
    );

    // Apply BackdropFilter blur with ClipRRect
    content = ClipRRect(
      borderRadius: effectiveRadius,
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );

    // Wrap with outer container for shadows & margins if defined
    if (boxShadow != null || margin != null) {
      content = Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: boxShadow,
        ),
        child: content,
      );
    }

    return content;
  }
}

/// Reusable Glass Card for elevated dashboards, KPI tiles, and modal content.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double blur;
  final BorderRadiusGeometry? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.blur = GlassTokens.blurMd,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadii.border2xl;

    Widget card = GlassContainer(
      blur: blur,
      borderRadius: effectiveRadius,
      padding: padding,
      boxShadow: GlassTokens.glassCardShadow,
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius is BorderRadius ? effectiveRadius : AppRadii.border2xl,
        child: card,
      );
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}

/// Reusable Glass Pill Capsule for floating badges, action tags, and indicators.
class GlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderSide? side;
  final VoidCallback? onTap;

  const GlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.color,
    this.side,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget pill = GlassContainer(
      blur: GlassTokens.blurSm,
      borderRadius: AppRadii.borderFull,
      padding: padding,
      color: color ?? GlassTokens.frostedUltraLight,
      border: Border.fromBorderSide(
        side ?? const BorderSide(color: GlassTokens.borderSubtle, width: 1.0),
      ),
      child: child,
    );

    if (onTap != null) {
      pill = InkWell(
        onTap: onTap,
        borderRadius: AppRadii.borderFull,
        child: pill,
      );
    }

    return pill;
  }
}
