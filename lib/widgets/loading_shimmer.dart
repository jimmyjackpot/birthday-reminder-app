import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'minimal_card.dart';

class LoadingShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppTheme.surfaceDark.withValues(alpha: 0.5)
        : AppTheme.getBorderColor(isDark);
    final highlightColor = isDark
        ? AppTheme.surfaceElevatedDark.withValues(alpha: 0.8)
        : AppTheme.getSurfaceColor(isDark);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(AppTheme.radiusMedium),
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 - _controller.value * 2, 0.0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class BirthdayCardShimmer extends StatelessWidget {
  const BirthdayCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const MinimalCard(
      elevation: 1,
      margin: EdgeInsets.only(bottom: AppTheme.spacingMD),
      child: Row(
        children: [
          LoadingShimmer(
            width: 56,
            height: 56,
            borderRadius:
                BorderRadius.all(Radius.circular(AppTheme.radiusMedium)),
          ),
          SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingShimmer(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(height: AppTheme.spacingSM),
                LoadingShimmer(
                  width: 120,
                  height: 12,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(height: AppTheme.spacingXS),
                LoadingShimmer(
                  width: 80,
                  height: 12,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
