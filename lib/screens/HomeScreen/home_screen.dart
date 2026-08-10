// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/HomeAppBar.dart';
import 'package:saleem_dry_clean/components/ImageSlider/BottomCurvedClipper.dart';
import 'package:saleem_dry_clean/components/ImageSlider/ImageSlider.dart';
import 'package:saleem_dry_clean/components/Notification/NotificationButton.dart';
import 'package:saleem_dry_clean/components/Stores/StoresBrowser.dart';
import 'package:saleem_dry_clean/services/Providers/BannerProvider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

/// الشاشة الرئيسية — قائمة المغاسل.
///
/// ★ لماذا تغيّرت جذرياً ★
///
/// كانت تعرض أربعة كروت لأنواع الخدمات (ملابس، سجاد، ستائر، مفروشات)،
/// والضغط عليها يفتح كتالوج المنصّة بسعر واحد. وهذا كان صحيحاً حين كانت
/// سليم هي من تغسل.
///
/// وفي نموذج الوسيط السؤال الأول صار «من يغسل» لا «ماذا أغسل»: لكل محل
/// أسعاره وأصنافه ومدّة تجهيزه. فصارت الرئيسية قائمة المغاسل، واختيار
/// الخدمة انتقل إلى داخل صفحة المحل حيث للأسعار معنى.
///
/// والطريق القديم لم يُترك معطَّلاً بل حُذف: طريقان للطلب أحدهما يتجاوز
/// اختيار المحل يعني سلّة بلا محل وأسعاراً لا تخصّ أحداً.
class HomeScreen extends StatefulWidget {
  final double fem;

  const HomeScreen({Key? key, required this.fem}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _lastLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = context.read<LanguageProvider>().locale.languageCode;
    if (_lastLanguage == lang) return;
    _lastLanguage = lang;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BannerProvider>().fetchBannerImages(lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bannerProvider = Provider.of<BannerProvider>(context);
    List<String> imagePaths = bannerProvider.bannerImages;
    List<String> displayImagePaths = imagePaths.isNotEmpty
        ? imagePaths
        : ['assets/images/default_banner.png'];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          StoresBrowser(
            title: l10n.translate('stores_choose_title'),
            subtitle: l10n.translate('stores_choose_subtitle'),
            header: ClipPath(
              clipper: BottomCurvedClipper(),
              child: Container(
                color: AppColors.white,
                child:
                    ImageSlider(imagePaths: displayImagePaths, fem: widget.fem),
              ),
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
