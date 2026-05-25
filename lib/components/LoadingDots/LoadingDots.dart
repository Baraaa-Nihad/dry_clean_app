import 'dart:math';

import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class LoadingDots extends StatefulWidget {
  final double fem;

  LoadingDots({required this.fem});

  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0 * widget.fem),
              child: Transform.translate(
                offset: Offset(0, _getWaveOffset(index)),
                child: Dot(
                    fem: widget.fem,
                    color: _controller.value > (index / 3) &&
                            _controller.value < ((index + 1) / 3)
                        ? AppColors.lodingActive
                        : AppColors.loadingInActive),
              ),
            );
          }),
        );
      },
    );
  }

  double _getWaveOffset(int index) {
    final waveValue = _controller.value + (index * 0.3);
    final sineValue = (waveValue * 2 * 3.14159265359) % (2 * 3.14159265359);
    return 4 * widget.fem * sin(sineValue);
  }
}

class Dot extends StatelessWidget {
  final double fem;
  final Color color;

  Dot({required this.fem, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.0 * fem,
      height: 10.0 * fem,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
