import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class CodeInputField extends StatelessWidget {
  final double fem;
  final TextEditingController controller;
  final bool isError;
  final bool isLoading;
  final bool isSuccess;
  final int length;
  final Function(String) onCompletedCallback;

  CodeInputField({
    required this.fem,
    required this.controller,
    this.isError = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.length = 4,
    required this.onCompletedCallback,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد لون الحدود بناءً على الحالة (نفس منطقك القديم)
    Color borderColor;
    if (isError) {
      borderColor = AppColors.red;
    } else if (isSuccess) {
      borderColor = AppColors.statusGreen;
    } else {
      borderColor = AppColors.gray20;
    }

    // التصميم الافتراضي للمربع (مطابق لـ PinTheme القديم)
    final defaultPinTheme = PinTheme(
      width: 56.0 * fem,
      height: 56.0 * fem,
      textStyle: AppTextStyles.getFontFamily(
        context,
        AppTextStyles.bold16Gray80(context).copyWith(
          fontSize: 16.0 * fem,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0 * fem),
        border: Border.all(color: borderColor), // يستخدم borderColor المتغير
      ),
    );

    // حالة التركيز (Selected Color)
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.gray70),
      ),
    );

    return Column(
      children: [
        Container(
          // الحفاظ على نفس مسافات الـ Container الأصلي
          padding: EdgeInsets.symmetric(horizontal: 8.0 * fem),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 90 * fem,
          ),
          child: Pinput(
            length: length,
            controller: controller,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme:
                defaultPinTheme, // يبقى بنفس لون الحالة (إيرور أو نجاح)
            // المسافة الأفقية بين المربعات (fieldOuterPadding سابقاً)
            separatorBuilder: (index) => SizedBox(width: 16.0 * fem),
            keyboardType: TextInputType.number,
            // استدعاء الكول باك عند الإتمام
            onCompleted: onCompletedCallback,
            // إغلاق الأنيميشن الافتراضي ليكون مطابقاً لـ fade
            animationDuration: const Duration(milliseconds: 300),
            hapticFeedbackType: HapticFeedbackType.disabled,
            showCursor: true,
            cursor: Container(
              width: 1,
              height: 24 * fem,
              color: AppColors.gray70,
            ),
          ),
        ),
        if (isLoading) ...[
          SizedBox(height: 20 * fem),
          LoadingDots(fem: fem),
        ],
      ],
    );
  }
}
