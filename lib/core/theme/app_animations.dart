import 'package:flutter/material.dart';

/// Central animation design system for WhatsApp Wiz.
///
/// All durations, curves, and transitions live here so every motion
/// is consistent and easy to tune from one place.
class AppAnimations {
  AppAnimations._();

  // ─── Durations ───────────────────────────────────────────────────────────
  /// Instant micro-feedback: ripple, icon state swap.
  static const Duration micro = Duration(milliseconds: 100);

  /// Fast: button press scale, badge pop, chip toggle.
  static const Duration fast = Duration(milliseconds: 160);

  /// Standard: card reveal, list item entrance, modal fade-in.
  static const Duration standard = Duration(milliseconds: 280);

  /// Comfortable: screen page transition, bottom-sheet slide.
  static const Duration comfortable = Duration(milliseconds: 380);

  /// Deliberate: hero expand, drawer slide, dialog entrance.
  static const Duration deliberate = Duration(milliseconds: 480);

  /// Long: skeleton shimmer cycle, loading wave.
  static const Duration long = Duration(milliseconds: 700);

  // ─── Curves ──────────────────────────────────────────────────────────────
  /// Material 3 standard easing (ease-in-out).
  static const Curve standard_ = Curves.easeInOutCubicEmphasized;

  /// Emphasised deceleration — good for things entering the screen.
  static const Curve enter = Curves.easeOutCubic;

  /// Emphasised acceleration — good for things leaving the screen.
  static const Curve exit = Curves.easeInCubic;

  /// Bouncy spring for pops and scale-in feedback.
  static const Curve spring = Curves.elasticOut;

  /// Soft ease for fades and opacity transitions.
  static const Curve fade = Curves.easeInOut;

  // ─── Stagger helpers ─────────────────────────────────────────────────────
  /// Returns the staggered delay for list item at [index], capped at [maxIndex].
  static Duration staggerDelay(int index, {
    int maxIndex = 8,
    Duration base = const Duration(milliseconds: 42),
  }) {
    final clamped = index.clamp(0, maxIndex);
    return base * clamped;
  }

  // ─── Page Transition Builders ────────────────────────────────────────────

  /// Soft fade + slight upward slide — used for all shell (tab) routes.
  static Widget fadeUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fade = CurvedAnimation(parent: animation, curve: enter);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: enter));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  /// Slide in from right — used for full-screen push routes (chat, detail pages).
  static Widget slideRightTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slide = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: enter));

    final fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: animation, curve: enter));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  /// Scale + fade — used for modal / overlay full-screen routes.
  static Widget scaleFadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleAnim = Tween<double>(begin: 0.94, end: 1.0)
        .animate(CurvedAnimation(parent: animation, curve: enter));
    final fadeAnim = CurvedAnimation(parent: animation, curve: fade);

    return FadeTransition(
      opacity: fadeAnim,
      child: ScaleTransition(scale: scaleAnim, child: child),
    );
  }
}
