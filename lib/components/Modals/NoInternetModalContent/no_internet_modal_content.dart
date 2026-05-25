// lib/screens/NoInternetPage/no_internet_modal_content.dart

import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/connectivityBanner/RetryComponent.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class NoInternetModalContent extends StatelessWidget {
  final double fem;
  final VoidCallback onRetry;

  const NoInternetModalContent({
    Key? key,
    required this.fem,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RetryComponent(
      svgAssetPath:
          'assets/Icons/no_internet_icon.svg', // Replace with your SVG asset
      title: 'Oops! No Internet',
      subtitle: 'Please check your connection.',
      onRetry: onRetry,
      fem: fem,
    );
  }
}
