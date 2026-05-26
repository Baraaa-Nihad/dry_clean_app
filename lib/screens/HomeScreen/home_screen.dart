// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:saleem_dry_clean/components/AppBar/HomeAppBar.dart';
import 'package:saleem_dry_clean/components/ImageSlider/BottomCurvedClipper.dart';
import 'package:saleem_dry_clean/components/ImageSlider/ImageSlider.dart';
import 'package:saleem_dry_clean/components/Notification/NotificationButton.dart';
import 'package:saleem_dry_clean/components/Services/ServiceTypesCardsSection.dart';
import 'package:saleem_dry_clean/services/Providers/BannerProvider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart'; // Import UserProvider
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';

class HomeScreen extends StatefulWidget {
  final double fem;

  const HomeScreen({Key? key, required this.fem}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final String lang = languageProvider.locale.languageCode;
    // Fetch banner images when the screen is initialized
    Provider.of<BannerProvider>(context, listen: false).fetchBannerImages(lang);
  }

  @override
  Widget build(BuildContext context) {
    final bannerProvider = Provider.of<BannerProvider>(context);
    List<String> imagePaths = bannerProvider.bannerImages;
    // Determine which images to display: fetched images or default image
    List<String> displayImagePaths = imagePaths.isNotEmpty
        ? imagePaths
        : ['assets/images/default_banner.png']; // Path to your default image

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ClipPath(
                  clipper: BottomCurvedClipper(),
                  child: Container(
                    color: AppColors.white,
                    child: ImageSlider(
                        imagePaths: displayImagePaths, fem: widget.fem),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * widget.fem),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ServiceTypesSection(fem: widget.fem),
                      // Add more widgets as needed
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          HomeAppBar(
            fem: widget.fem,
            quantityNumber: true,
            suffixIconPath: NotificationButton(),
            onPrefixIconTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
