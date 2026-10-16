import 'package:flutter/material.dart';
import '../../core/theme/app_radii.dart';
import 'shimmer_box.dart';

enum SkeletonType {
  /// Avatar + text rows + trailing badge (Inbox, Contacts)
  tile,

  /// Card with header, badge, multiline content, and action button (Templates, Campaigns, Flows)
  card,

  /// 2-column stat card grid (Dashboard)
  statGrid,
}

class SkeletonList extends StatelessWidget {
  final int count;
  final double? itemHeight;
  final SkeletonType type;
  final EdgeInsetsGeometry padding;

  const SkeletonList({
    super.key,
    this.count = 6,
    this.itemHeight,
    this.type = SkeletonType.tile,
    this.padding = const EdgeInsets.all(16),
  });

  const SkeletonList.cards({
    super.key,
    this.count = 4,
    this.itemHeight,
    this.padding = const EdgeInsets.all(16),
  }) : type = SkeletonType.card;

  const SkeletonList.stats({
    super.key,
    this.count = 4,
    this.itemHeight,
    this.padding = const EdgeInsets.all(16),
  }) : type = SkeletonType.statGrid;

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (type) {
      case SkeletonType.statGrid:
        return _buildStatGrid();
      case SkeletonType.card:
        return _buildCardList();
      case SkeletonType.tile:
        return _buildTileList();
    }
  }

  Widget _buildTileList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: padding,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: itemHeight ?? 76,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.border2xl,
          border: Border.all(color: const Color(0x1F22C55E), width: 1),
        ),
        child: const Row(
          children: [
            ShimmerBox.circular(size: 46),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 120, height: 14),
                      ShimmerBox(width: 44, height: 10),
                    ],
                  ),
                  SizedBox(height: 8),
                  ShimmerBox(width: 180, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: padding,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.border2xl,
          border: Border.all(color: const Color(0x1F22C55E), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 140, height: 16),
                ShimmerBox(width: 64, height: 20),
              ],
            ),
            const SizedBox(height: 10),
            const ShimmerBox(width: 90, height: 12),
            const SizedBox(height: 12),
            const ShimmerBox(width: double.infinity, height: 12),
            const SizedBox(height: 6),
            const ShimmerBox(width: 220, height: 12),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: ShimmerBox(width: 110, height: 32, borderRadius: BorderRadius.circular(8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          // Banner card placeholder
          Container(
            height: 110,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.border2xl,
              border: Border.all(color: const Color(0x1F22C55E), width: 1),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 150, height: 16),
                    ShimmerBox(width: 70, height: 20),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ShimmerBox(width: 70, height: 28),
                    ShimmerBox(width: 70, height: 28),
                    ShimmerBox(width: 70, height: 28),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 2x2 grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.border2xl,
                border: Border.all(color: const Color(0x1F22C55E), width: 1),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 80, height: 12),
                      ShimmerBox(width: 28, height: 28),
                    ],
                  ),
                  ShimmerBox(width: 60, height: 22),
                  ShimmerBox(width: 90, height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
