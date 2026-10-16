import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/modal_sheet.dart';
import '../../domain/campaign.dart';

class CampaignAnalyticsSheet extends StatelessWidget {
  final Campaign campaign;

  const CampaignAnalyticsSheet({super.key, required this.campaign});

  static void show(BuildContext context, Campaign campaign) {
    ModalSheet.show(
      context: context,
      title: 'Campaign Analytics',
      subtitle: campaign.name,
      child: CampaignAnalyticsSheet(campaign: campaign),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Funnel Stats Grid
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Total Targeted', value: '${campaign.totalRecipients}', color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            Expanded(child: _StatBox(label: 'Sent', value: '${campaign.sentCount}', color: AppColors.g700)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Delivered', value: '${campaign.deliveredCount}', color: AppColors.waTeal)),
            const SizedBox(width: 8),
            Expanded(child: _StatBox(label: 'Read / Opened', value: '${campaign.readCount}', color: AppColors.g600)),
          ],
        ),
        const SizedBox(height: 20),

        // Funnel Bar Chart with fl_chart
        const Text('Delivery Funnel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (campaign.totalRecipients > 0 ? campaign.totalRecipients : 100).toDouble() * 1.15,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      switch (val.toInt()) {
                        case 0:
                          return const Text('Sent', style: TextStyle(fontSize: 11));
                        case 1:
                          return const Text('Delivered', style: TextStyle(fontSize: 11));
                        case 2:
                          return const Text('Read', style: TextStyle(fontSize: 11));
                        case 3:
                          return const Text('Failed', style: TextStyle(fontSize: 11));
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: campaign.sentCount.toDouble(),
                      color: AppColors.g700,
                      width: 20,
                      borderRadius: AppRadii.borderSm,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: campaign.deliveredCount.toDouble(),
                      color: AppColors.waTeal,
                      width: 20,
                      borderRadius: AppRadii.borderSm,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: campaign.readCount.toDouble(),
                      color: AppColors.g600,
                      width: 20,
                      borderRadius: AppRadii.borderSm,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [
                    BarChartRodData(
                      toY: campaign.failedCount.toDouble(),
                      color: AppColors.statusRedText,
                      width: 20,
                      borderRadius: AppRadii.borderSm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.g50,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: AppColors.g200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
