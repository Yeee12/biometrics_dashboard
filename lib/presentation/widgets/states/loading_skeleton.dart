import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(height: 40, width: 250),
            const SizedBox(height: 8),
            _ShimmerBox(height: 16, width: 400),
            const SizedBox(height: 24),
            Row(
              children: [
                _ShimmerBox(height: 32, width: 60),
                const SizedBox(width: 8),
                _ShimmerBox(height: 32, width: 60),
                const SizedBox(width: 8),
                _ShimmerBox(height: 32, width: 60),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _ShimmerBox(height: 120)),
                const SizedBox(width: 12),
                Expanded(child: _ShimmerBox(height: 120)),
                const SizedBox(width: 12),
                Expanded(child: _ShimmerBox(height: 120)),
              ],
            ),
            const SizedBox(height: 24),
            _ShimmerBox(height: AppConstants.chartHeight + 60),
            const SizedBox(height: 16),
            _ShimmerBox(height: AppConstants.chartHeight + 60),
            const SizedBox(height: 16),
            _ShimmerBox(height: AppConstants.chartHeight + 60),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;

  const _ShimmerBox({required this.height, this.width});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0),
              end: Alignment(1.0 - _controller.value * 2, 0),
              colors: [
                AppConstants.surfaceDark,
                AppConstants.surfaceDark.withOpacity(0.5),
                AppConstants.surfaceDark,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}