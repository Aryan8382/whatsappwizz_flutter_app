import 'package:flutter/material.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';

class SavingsTrackerCard extends StatelessWidget {
  final double costSavedInr;
  final int freeMessages;
  final double resolutionRate;
  final double metaFeesCharged;

  const SavingsTrackerCard({
    super.key,
    required this.costSavedInr,
    required this.freeMessages,
    required this.resolutionRate,
    this.metaFeesCharged = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF0FDF6),
            Color(0xFFDCFCE9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.border3xl,
        border: Border.all(color: const Color(0x6622C55E), width: 1.2),
        boxShadow: AppShadows.greenGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.piggyBank,
                  color: AppColors.g700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '24H Free Window Savings',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.g950),
                    ),
                    Text(
                      'Meta Template Fee Optimization (₹0.75/conv avg)',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.g800),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.g600,
                  borderRadius: AppRadii.borderFull,
                ),
                child: Text(
                  metaFeesCharged <= 0
                      ? '₹0.00 Meta Fee'
                      : '₹${metaFeesCharged.toStringAsFixed(2)} Fee',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SavingsMetricItem(
                  label: 'Cost Saved',
                  value: '₹${costSavedInr.toStringAsFixed(0)}',
                  highlight: true,
                ),
              ),
              Container(width: 1, height: 44, color: AppColors.g300),
              Expanded(
                child: _SavingsMetricItem(
                  label: 'Free Messages',
                  value: '$freeMessages',
                ),
              ),
              Container(width: 1, height: 44, color: AppColors.g300),
              Expanded(
                child: _SavingsMetricItem(
                  label: 'Resolution Rate',
                  value: '$resolutionRate%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavingsMetricItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SavingsMetricItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 22 : 20,
            fontWeight: FontWeight.w800,
            color: highlight ? AppColors.g800 : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
