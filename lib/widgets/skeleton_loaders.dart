import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable skeleton block matching app card shapes
class SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton for Dashboard Tab — matches routine cards + weekly performance layout
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withAlpha(15),
      highlightColor: Colors.white.withAlpha(30),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SkeletonBlock(width: 220, height: 32, borderRadius: 8),
                  SkeletonBlock(width: 44, height: 44, shape: BoxShape.circle),
                ],
              ),
              const SizedBox(height: 32),
              // Section title
              const SkeletonBlock(width: 120, height: 20, borderRadius: 6),
              const SizedBox(height: 16),
              // Routine cards
              const SkeletonBlock(width: double.infinity, height: 70, borderRadius: 20),
              const SizedBox(height: 12),
              const SkeletonBlock(width: double.infinity, height: 70, borderRadius: 20),
              const SizedBox(height: 12),
              const SkeletonBlock(width: double.infinity, height: 70, borderRadius: 20),
              const SizedBox(height: 32),
              // Weekly Performance title
              const SkeletonBlock(width: 180, height: 20, borderRadius: 6),
              const SizedBox(height: 16),
              // Weekly chart card
              const SkeletonBlock(width: double.infinity, height: 200, borderRadius: 24),
              const SizedBox(height: 32),
              // Activity section title
              const SkeletonBlock(width: 160, height: 20, borderRadius: 6),
              const SizedBox(height: 16),
              // Activity cards horizontal
              SizedBox(
                height: 140,
                child: Row(
                  children: const [
                    Expanded(child: SkeletonBlock(width: double.infinity, height: 140, borderRadius: 20)),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonBlock(width: double.infinity, height: 140, borderRadius: 20)),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for Check-In Tab — matches routine cards + category squares + activity list
class CheckInSkeleton extends StatelessWidget {
  const CheckInSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withAlpha(15),
      highlightColor: Colors.white.withAlpha(30),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              const SkeletonBlock(width: 180, height: 28, borderRadius: 8),
              const SizedBox(height: 32),
              // Daily Tasks title
              const SkeletonBlock(width: 120, height: 20, borderRadius: 6),
              const SizedBox(height: 16),
              // Routine cards
              const SkeletonBlock(width: double.infinity, height: 70, borderRadius: 20),
              const SizedBox(height: 12),
              const SkeletonBlock(width: double.infinity, height: 70, borderRadius: 20),
              const SizedBox(height: 32),
              // Categories title
              const SkeletonBlock(width: 120, height: 20, borderRadius: 6),
              const SizedBox(height: 6),
              const SkeletonBlock(width: 200, height: 14, borderRadius: 4),
              const SizedBox(height: 20),
              // Category square cards
              SizedBox(
                height: 165,
                child: Row(
                  children: const [
                    SkeletonBlock(width: 165, height: 165, borderRadius: 28),
                    SizedBox(width: 12),
                    SkeletonBlock(width: 165, height: 165, borderRadius: 28),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Activity section title
              const SkeletonBlock(width: 180, height: 20, borderRadius: 6),
              const SizedBox(height: 16),
              // Activity list cards
              const SkeletonBlock(width: double.infinity, height: 68, borderRadius: 16),
              const SizedBox(height: 10),
              const SkeletonBlock(width: double.infinity, height: 68, borderRadius: 16),
              const SizedBox(height: 10),
              const SkeletonBlock(width: double.infinity, height: 68, borderRadius: 16),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for Stats Tab — matches time selector + trend card + stat cards
class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withAlpha(15),
      highlightColor: Colors.white.withAlpha(30),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SkeletonBlock(width: 140, height: 28, borderRadius: 8),
                  SkeletonBlock(width: 44, height: 44, shape: BoxShape.circle),
                ],
              ),
              const SizedBox(height: 24),
              // Time selector
              const SkeletonBlock(width: double.infinity, height: 48, borderRadius: 14),
              const SizedBox(height: 24),
              // Trends card
              const SkeletonBlock(width: double.infinity, height: 250, borderRadius: 24),
              const SizedBox(height: 20),
              // Two side-by-side cards
              SizedBox(
                height: 200,
                child: Row(
                  children: const [
                    Expanded(child: SkeletonBlock(width: double.infinity, height: 200, borderRadius: 24)),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonBlock(width: double.infinity, height: 200, borderRadius: 24)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Streak card
              const SkeletonBlock(width: double.infinity, height: 180, borderRadius: 24),
              const SizedBox(height: 20),
              // Records card
              const SkeletonBlock(width: double.infinity, height: 180, borderRadius: 24),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton for Profile Tab — matches profile avatar + settings list
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withAlpha(15),
      highlightColor: Colors.white.withAlpha(30),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Profile avatar
              const SkeletonBlock(width: 100, height: 100, shape: BoxShape.circle),
              const SizedBox(height: 16),
              const SkeletonBlock(width: 160, height: 24, borderRadius: 8),
              const SizedBox(height: 8),
              const SkeletonBlock(width: 200, height: 14, borderRadius: 4),
              const SizedBox(height: 32),
              // Stats row
              SizedBox(
                height: 80,
                child: Row(
                  children: const [
                    Expanded(child: SkeletonBlock(width: double.infinity, height: 80, borderRadius: 20)),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonBlock(width: double.infinity, height: 80, borderRadius: 20)),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonBlock(width: double.infinity, height: 80, borderRadius: 20)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Settings list items
              const SkeletonBlock(width: double.infinity, height: 56, borderRadius: 16),
              const SizedBox(height: 12),
              const SkeletonBlock(width: double.infinity, height: 56, borderRadius: 16),
              const SizedBox(height: 12),
              const SkeletonBlock(width: double.infinity, height: 56, borderRadius: 16),
              const SizedBox(height: 12),
              const SkeletonBlock(width: double.infinity, height: 56, borderRadius: 16),
              const SizedBox(height: 12),
              const SkeletonBlock(width: double.infinity, height: 56, borderRadius: 16),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
