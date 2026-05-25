import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:saleem_dry_clean/components/Indicator/CustomIndicator.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ImageLoader.dart';

class ImageSlider extends StatefulWidget {
  final List<String> imagePaths;
  final double fem;

  const ImageSlider({
    Key? key,
    required this.imagePaths,
    required this.fem,
  }) : super(key: key);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _current = 0;
  late CarouselSliderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Use LayoutBuilder to ensure full width
        LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              child: CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                  height: 340.50 * widget.fem,
                  viewportFraction: 1.0, // Make the slider take full width
                  enlargeCenterPage: false, // Do not enlarge the center page
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  initialPage: widget.imagePaths.length - 1,
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                ),
                items: widget.imagePaths.map((imagePath) {
                  return Builder(
                    builder: (context) {
                      return Container(
                        width: constraints.maxWidth, // Use the full width
                        decoration: BoxDecoration(
                          color: AppColors.gray10,
                        ),
                        child: ImageLoader(
                          imageUrl: imagePath, // Use the ImageLoader here
                          height: 340.50 * widget.fem,
                          width: constraints.maxWidth,
                          borderRadius: 0, // Adjust if you want rounded corners
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
        Positioned(
          bottom: 30 * widget.fem,
          child: CustomIndicator(
            activeIndex: _current,
            count: widget.imagePaths.length,
            fem: widget.fem,
          ),
        ),
      ],
    );
  }
}
