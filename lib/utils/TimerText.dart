import 'package:flutter/material.dart';
import 'dart:async';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/app_theme.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class CountdownTimer extends StatefulWidget {
  final double fem;
  final int duration;
  final VoidCallback onTimerComplete;
  final VoidCallback onResendCode;
  final bool showResendButton;
  final bool isLoading;

  const CountdownTimer({
    Key? key,
    required this.fem,
    this.duration = 60,
    required this.onTimerComplete,
    required this.onResendCode,
    this.showResendButton = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Changed interval to 2 seconds
      if (_remainingTime <= 0) {
        widget.onTimerComplete();
        _timer?.cancel();
      } else {
        setState(() {
          _remainingTime -= 1; // Decrease by 2 seconds
          if (_remainingTime < 0) {
            _remainingTime = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime % 60).toString().padLeft(2, '0');
    final textDirection = Directionality.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: GestureDetector(
        onTap: widget.isLoading || _remainingTime > 0
            ? null
            : () {
                widget.onResendCode();
                setState(() {
                  _remainingTime = widget.duration;
                  _startTimer();
                });
              },
        child: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.getPrimaryGradient(context).createShader(bounds),
          child: Text(
            !widget.isLoading
                ? _remainingTime > 0
                    ? '${localizations?.translate('resend_in') ?? 'Resend in'} $minutes:$seconds'
                    : localizations?.translate('resend') ?? 'Resend'
                : '',
            textAlign: TextAlign.center,
            style: AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              height: 1.5,
            ),
            textDirection: textDirection,
          ),
        ),
      ),
    );
  }
}
