import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/StoreCard.dart';
import 'package:saleem_dry_clean/utils/store_favorite_action.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/StoresProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

/// المغاسل المفضّلة (٢.١.٨).
///
/// ★ لماذا تقرأ من StoresProvider لا من مسار مستقلّ ★
///
/// المفضّلة ليست قائمة أخرى بل ترشيح للقائمة نفسها، وكل محل يحمل
/// `isFavorite` أصلاً. ومزوّد ثانٍ يعني حالة قلب في مكانين: يُزيل
/// الزبون محلاً من هنا فيبقى قلبه ملوّناً في الرئيسية.
class FavoriteStoresScreen extends StatefulWidget {
  const FavoriteStoresScreen({super.key});

  @override
  State<FavoriteStoresScreen> createState() => _FavoriteStoresScreenState();
}

class _FavoriteStoresScreenState extends State<FavoriteStoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // بلا منطقة: المفضّلة تتجاوز الترشيح الجغرافي — الزبون قد يفضّل
      // محلاً في مدينة أهله ويزورهم كل شهر
      final p = context.read<StoresProvider>();
      if (p.stores.isEmpty) p.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StoresProvider>();
    final favorites = p.stores.where((s) => s.isFavorite).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray80,
        elevation: 0,
        title: Text(
          'المغاسل المفضّلة',
          style: AppTextStyles.sfarabicBold
              .copyWith(fontSize: 16.5, color: AppColors.gray80),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.green,
        onRefresh: () => context.read<StoresProvider>().load(force: true),
        child: favorites.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  const SizedBox(height: 70),
                  const Icon(Icons.favorite_border,
                      size: 54, color: AppColors.inactiveColor),
                  const SizedBox(height: 14),
                  Text(
                    'لا مغاسل في مفضّلتك',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sfarabicBold
                        .copyWith(fontSize: 15, color: AppColors.gray80),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'اضغط القلب على أي مغسلة لتظهر هنا',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sfarabicRegular.copyWith(
                        fontSize: 12.5, color: AppColors.secondaryTextColor),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                itemCount: favorites.length,
                itemBuilder: (_, i) {
                  final store = favorites[i];
                  return StoreCard(
                    store: store,
                    onTap: () => NavigatorService.navigateTo(
                      RouteNames.storeCatalog,
                      arguments: {'store': store},
                    ),
                    onFavoriteTap: () => toggleStoreFavorite(
                      context,
                      storeId: store.id,
                      currentValue: store.isFavorite,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
