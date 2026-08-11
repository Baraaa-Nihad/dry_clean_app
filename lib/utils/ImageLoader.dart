import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class ImageLoader extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final double borderRadius;
  final BoxFit fit;

  const ImageLoader({
    Key? key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.borderRadius = 16.0,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  String get _resolvedImageUrl => Config.resolveImageUrl(imageUrl);

  bool get _isNetwork =>
      _resolvedImageUrl.startsWith('http://') ||
      _resolvedImageUrl.startsWith('https://');

  bool get _isSvg =>
      _resolvedImageUrl.toLowerCase().endsWith('.svg') ||
      _resolvedImageUrl.toLowerCase().contains('.svg?');

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.gray20, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (_isNetwork && _isSvg) {
      return SvgPicture.network(
        _resolvedImageUrl,
        height: height,
        width: width,
        fit: fit,
        placeholderBuilder: (_) => _shimmer(),
      );
    }

    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: _resolvedImageUrl,
        height: height,
        width: width,
        fit: fit,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) => _shimmer(),
        errorWidget: (context, url, error) {
          debugPrint('ImageLoader: failed to load $url — $error');
          return _errorPlaceholder();
        },
      );
    }

    if (_isSvg) {
      return SvgPicture.asset(
        _resolvedImageUrl,
        fit: fit,
        height: height,
        width: width,
      );
    }

    return Image.asset(
      _resolvedImageUrl,
      fit: fit,
      height: height,
      width: width,
      errorBuilder: (_, __, ___) => _errorPlaceholder(),
    );
  }
}
