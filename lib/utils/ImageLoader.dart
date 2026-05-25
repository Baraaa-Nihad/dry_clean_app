import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

/// A drop-in image widget that:
/// - Caches network images to disk via [CachedNetworkImage] (instant on repeat views)
/// - Shows a shimmer placeholder while the image loads
/// - Shows a gallery-icon placeholder on error
/// - Uses the local placeholder for remote SVGs to avoid uncaught HTTP errors
/// - Falls back to [Image.asset] / [SvgPicture.asset] for local asset paths
class ImageLoader extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final double borderRadius;

  const ImageLoader({
    Key? key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.borderRadius = 16.0,
  }) : super(key: key);

  bool get _isNetwork =>
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  bool get _isSvg =>
      imageUrl.toLowerCase().endsWith('.svg') ||
      imageUrl.toLowerCase().contains('.svg?');

  Widget _shimmer() => Shimmer.fromColors(
        baseColor: AppColors.gray10,
        highlightColor: AppColors.gray20,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      );

  Widget _errorPlaceholder() => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: AppColors.gray10,
          border: Border.all(color: AppColors.gray20, width: 1),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/Icons/gallery.svg',
            width: 48,
            height: 48,
            colorFilter: ColorFilter.mode(AppColors.gray50, BlendMode.srcIn),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    // ── Network SVG ──────────────────────────────────────────────────────────
    // flutter_svg 2.0.9 does not expose an errorBuilder for network SVGs.
    // Avoid letting HTTP errors escape to FlutterError.onError.
    if (_isNetwork && _isSvg) {
      debugPrint('ImageLoader: remote SVG skipped $imageUrl');
      return _errorPlaceholder();
    }

    // ── Network raster image ─────────────────────────────────────────────────
    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        // No fade animations — the shimmer itself communicates loading state.
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) => _shimmer(),
        errorWidget: (context, url, error) {
          debugPrint('ImageLoader: failed to load $url — $error');
          return _errorPlaceholder();
        },
      );
    }

    // ── Local asset SVG ──────────────────────────────────────────────────────
    if (_isSvg) {
      return SvgPicture.asset(
        imageUrl,
        fit: BoxFit.cover,
        height: height,
        width: width,
      );
    }

    // ── Local asset raster ───────────────────────────────────────────────────
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      height: height,
      width: width,
      errorBuilder: (_, __, ___) => _errorPlaceholder(),
    );
  }
}
