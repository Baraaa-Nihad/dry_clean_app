// lib/widgets/ThumbnailImageLoader.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:shimmer/shimmer.dart';

class ThumbnailImageLoader extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderRadius;

  const ThumbnailImageLoader({
    Key? key,
    required this.imageUrl,
    required this.size,
    this.borderRadius = 16.0, // Default border radius
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if the image URL is a network URL
    final bool isNetworkImage = imageUrl.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: isNetworkImage
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              // Disable fade-in and fade-out animations
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              // Placeholder shimmer effect
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: AppColors.gray20,
                highlightColor: AppColors.gray10,
                child: Container(
                  width: size,
                  height: size,
                  color: AppColors.gray20,
                ),
              ),
              // Error widget with default image
              errorWidget: (context, url, error) {
                // Log the error for debugging
                debugPrint('Failed to load image: $url, Error: $error');
                return Image.asset(
                  'assets/images/placeholder.jpg', // Path to your default image
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  semanticLabel: 'Default placeholder image',
                );
              },
            )
          : Image.asset(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              semanticLabel: 'Local thumbnail image',
              errorBuilder: (context, error, stackTrace) => Container(
                width: size,
                height: size,
                color: AppColors.gray10,
              ),
            ),
    );
  }
}
