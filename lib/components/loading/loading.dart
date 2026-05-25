import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class LoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final int dotCount;

  const LoadingIndicator({
    Key? key,
    this.color = AppColors.blue,
    this.size = 10.0,
    this.dotCount = 3,
  }) : super(key: key);

  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Opacity(
              opacity: _animation.value < 0.5 ? 0.5 : 1.0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
