import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppPrimaryButtonStyles.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class LoadingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isDisabled;
  final bool isLoading;
  final double fem;
  final String buttonText;
  final String buttonWidth;

  const LoadingButton({
    Key? key,
    this.onPressed,
    this.isDisabled = false,
    this.isLoading = false,
    required this.fem,
    required this.buttonText,
    this.buttonWidth = 'full',
  }) : super(key: key);

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Opacity(
              opacity: _animation.value < 0.5 ? 0.5 : 1.0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2.0 * widget.fem),
                width: 8 * widget.fem,
                height: 8 * widget.fem,
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

  double _getWidth() {
    switch (widget.buttonWidth) {
      case 'small':
        return 146;
      case 'petiteMedium':
        return 173;
      case 'medium':
        return 182;
      case 'large':
        return 272;
      case 'full':
      default:
        return 380;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _getWidth();

        return Container(
          width: width,
          height: 56 * widget.fem,
          decoration: AppPrimaryButtonStyles.getDecoration(widget.isDisabled),
          child: ElevatedButton(
            onPressed:
                widget.isDisabled || widget.isLoading ? null : widget.onPressed,
            style: AppPrimaryButtonStyles.getButtonStyle(
                context, widget.isDisabled),
            child: widget.isLoading
                ? _buildLoadingIndicator()
                : Text(
                    widget.buttonText,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 16.0 * widget.fem,
                          fontWeight: FontWeight.w600,
                          height: 0,
                          color: AppColors.white),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
