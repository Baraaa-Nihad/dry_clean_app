import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/StoresProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

/// قسم المغاسل في الصفحة الرئيسية.
///
/// ★ لماذا في الرئيسية ★
///
/// كانت الرئيسية تعرض أنواع الخدمات وحدها لأن المغسلة كانت واحدة — سليم
/// نفسها. وفي نموذج الوسيط صار «من يغسل» سؤالاً قائماً بذاته، وإخفاؤه
/// خلف تدفّق الطلب يعني أن الزبون لا يعرف أن أمامه خياراً أصلاً.
///
/// أفقي لا رأسي: القسم مقدّمة لا قائمة، والقائمة الكاملة خلف «عرض الكل».
class HomeStoresSection extends StatefulWidget {
  const HomeStoresSection({super.key, this.fem = 1});

  final double fem;

  @override
  State<HomeStoresSection> createState() => _HomeStoresSectionState();
}

class _HomeStoresSectionState extends State<HomeStoresSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoresProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StoresProvider>();

    // لا مغاسل ولا تحميل: القسم يختفي كاملاً بدل عرض عنوان فوق فراغ
    if (p.stores.isEmpty && !p.isLoading) return const SizedBox.shrink();

    final preview = p.stores.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'المغاسل',
                style: AppTextStyles.sfarabicBold
                    .copyWith(fontSize: 17, color: AppColors.gray80),
              ),
            ),
            TextButton(
              onPressed: () =>
                  NavigatorService.navigateTo(RouteNames.stores),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'عرض الكل',
                style: AppTextStyles.sfarabicMedium
                    .copyWith(fontSize: 13, color: AppColors.green),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 158,
          child: p.isLoading && preview.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.green))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: preview.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _MiniStoreCard(store: preview[i]),
                ),
        ),
      ],
    );
  }
}

/// بطاقة مصغّرة — غلاف واسم وتقييم فقط.
///
/// أقلّ ممّا في StoreCard عمداً: القسم للتعريف بالخيارات لا للمفاضلة
/// بينها، والمفاضلة تحتاج شاشة بعرض كامل.
class _MiniStoreCard extends StatelessWidget {
  const _MiniStoreCard({required this.store});
  final Store store;

  @override
  Widget build(BuildContext context) {
    final disabled = !store.canOrder;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: SizedBox(
        width: 168,
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: disabled
                ? null
                : () => NavigatorService.navigateTo(
                      RouteNames.storeCatalog,
                      arguments: {'store': store},
                    ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 86,
                  child: (store.coverUrl ?? '').isEmpty
                      ? const DecoratedBox(
                          decoration:
                              BoxDecoration(gradient: AppColors.gradient),
                        )
                      : Image.network(
                          Config.resolveImageUrl(store.coverUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const DecoratedBox(
                            decoration:
                                BoxDecoration(gradient: AppColors.gradient),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        store.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sfarabicBold
                            .copyWith(fontSize: 13.5, color: AppColors.gray80),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (store.hasRating) ...[
                            const Icon(Icons.star_rounded,
                                size: 14, color: AppColors.orangeCard),
                            const SizedBox(width: 2),
                            Text(
                              store.rating.toStringAsFixed(1),
                              style: AppTextStyles.poppinsMedium.copyWith(
                                  fontSize: 11.5, color: AppColors.gray60),
                            ),
                          ] else
                            Text(
                              'جديدة',
                              style: AppTextStyles.sfarabicMedium.copyWith(
                                  fontSize: 11,
                                  color: AppColors.secondaryTextColor),
                            ),
                          if (store.turnaroundLabel != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.schedule,
                                size: 13, color: AppColors.inactiveColor),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                store.turnaroundLabel!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.sfarabicRegular.copyWith(
                                    fontSize: 11,
                                    color: AppColors.secondaryTextColor),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
