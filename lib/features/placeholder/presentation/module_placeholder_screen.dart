import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/animated_entrance.dart';

class ModulePlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ModulePlaceholderScreen({
    super.key,
    required this.title,
    this.description = 'This module is currently under active development and will be available in the upcoming release.',
    this.icon = LucideIcons.hammer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: FadeSlideIn(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.g100,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.g300, width: 2),
                ),
                child: Icon(icon, size: 44, color: AppColors.g700),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusAmberBg,
                  borderRadius: AppRadii.borderFull,
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.statusAmberText,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
