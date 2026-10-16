import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NavigationProgress extends StatelessWidget {
  final bool isNavigating;

  const NavigationProgress({
    super.key,
    this.isNavigating = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isNavigating) return const SizedBox(height: 2);

    return const SizedBox(
      height: 2,
      child: LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.g500),
      ),
    );
  }
}
