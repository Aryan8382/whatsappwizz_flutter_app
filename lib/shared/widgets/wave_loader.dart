import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';

class WaveLoader extends StatefulWidget {
  final bool ready;
  final Duration fadeDuration;

  const WaveLoader({
    super.key,
    required this.ready,
    this.fadeDuration = const Duration(milliseconds: 500),
  });

  @override
  State<WaveLoader> createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<WaveLoader> with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _trackController;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();

    _trackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    if (widget.ready) {
      _hideAfterDelay();
    }
  }

  @override
  void didUpdateWidget(covariant WaveLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ready && !oldWidget.ready) {
      _hideAfterDelay();
    }
  }

  void _hideAfterDelay() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _trackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: widget.fadeDuration,
      opacity: widget.ready ? 0.0 : 1.0,
      curve: Curves.easeOut,
      child: Stack(
        children: [
          // Background frosted tint
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: AppColors.g50.withOpacity(0.85),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: AppRadii.border4xl,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: AppShadows.glassLg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'WhatsApp Wiz',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.g700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3 Bouncing Dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _bounceController,
                        builder: (context, child) {
                          final delay = index * 0.18;
                          final progress = (_bounceController.value - delay) % 1.0;
                          final yOffset = -8.0 * (1.0 - (progress * 2 - 1).abs().clamp(0.0, 1.0));
                          final scale = 0.8 + 0.4 * (1.0 - (progress * 2 - 1).abs().clamp(0.0, 1.0));

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            transform: Matrix4.translationValues(0, yOffset, 0)..scale(scale),
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppColors.waGreen, AppColors.waTeal],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x6625D366),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Thin Progress Track
                  Container(
                    width: 120,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.g200,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedBuilder(
                      animation: _trackController,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _trackController.value,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.waGreen, AppColors.waTeal],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
