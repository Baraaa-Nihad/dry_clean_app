import 'package:saleem_dry_clean/ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/theme/AppIcons.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

/// بطاقة المحل في قائمة الاختيار.
///
/// ★ ما تحمله البطاقة وما لا تحمله ★
///
/// الزبون يفاضل بين محلات لا يعرف أيّها أفضل، فالبطاقة تجيب أسئلته
/// الأربعة بلمحة: هل هو جيّد (تقييم وعدد طلبات)، وكم يكلّف (متوسّط
/// السعر)، ومتى يجهز (مدّة التجهيز)، وهل أستطيع الطلب منه أصلاً (حدّ
/// أدنى وعدد أصناف).
///
/// وما لا تحمله: هاتف المحل وعنوانه الكامل. الزبون لا يزور المحل — سليم
/// تأخذ الغسيل وتعيده — فعرضهما يزحم البطاقة بما لا يُستعمل.
class StoreCard extends StatelessWidget {
  const StoreCard({
    super.key,
    required this.store,
    this.onTap,
    this.onFavoriteTap,
  });

  final Store store;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final disabled = !store.canOrder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Opacity(
        // المحل بلا أصناف يُعرض باهتاً لا مخفياً: إخفاؤه يجعل الزبون
        // يسأل «أين المحل الذي رأيته أمس»
        opacity: disabled ? 0.55 : 1,
        child: Material(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.gray20),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: disabled ? null : onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
                  child: _StoreHeader(
                    store: store,
                    onFavoriteTap: onFavoriteTap,
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.gray20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StoreDetails(store: store),
                      if (store.hasActiveOffer || disabled) ...[
                        const SizedBox(height: 12),
                        if (store.hasActiveOffer)
                          _StatusPill(
                            icon: AppIcons.offer,
                            label: (store.discountPercent ?? 0) > 0
                                ? l10n.translate(
                                    'store_discount_up_to',
                                    params: {
                                      'discount': '${store.discountPercent}'
                                    },
                                  )
                                : l10n.translate('store_offer_available'),
                            background: AppColors.orangeCardBackgourd,
                          ),
                        if (disabled)
                          _StatusPill(
                            icon: AppIcons.info,
                            label: l10n.translate('store_pricing_unavailable'),
                            background: AppColors.orangeCardBackgourd,
                          ),
                      ],
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

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.store, this.onFavoriteTap});

  final Store store;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _StoreLogo(store: store),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                store.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sfarabicBold.copyWith(
                  fontSize: 16,
                  color: AppColors.gray80,
                ),
              ),
              if ((store.description ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  store.description!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sfarabicRegular.copyWith(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _CompactRating(store: store),
            const SizedBox(height: 7),
            Material(
              color: AppColors.gray10,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onFavoriteTap,
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  // ★ الفراغ والامتلاء ★
                  //
                  // القلب فارغ حتى يُضغط: الشكل نفسه يحمل الحالتين، فلا
                  // يتعلّم الزبون أيقونتين لمعنى واحد.
                  //
                  // والانتقال متدرّج لا قفزة — الضغط يقع والقلب يمتلئ
                  // أمام العين، فيتأكّد أن فعله وصل.
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: SvgPicture.asset(
                      store.isFavorite
                          ? AppIcons.heartFilled
                          : AppIcons.heart,
                      key: ValueKey<bool>(store.isFavorite),
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StoreLogo extends StatelessWidget {
  const _StoreLogo({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final raw = (store.logoUrl ?? '').trim();
    final image = Config.resolveImageUrl(raw);

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.blueCardBackgourd,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray20),
      ),
      clipBehavior: Clip.antiAlias,
      child: raw.isEmpty
          ? const _LogoFallback()
          : image.startsWith('assets/')
              ? Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _LogoFallback(),
                )
              : Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _LogoFallback(),
                ),
    );
  }
}

class _CompactRating extends StatelessWidget {
  const _CompactRating({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ممتلئة: التقييم حقيقة مثبتة لا خيار يُضغط
        SvgPicture.asset(AppIcons.ratingStar, width: 17, height: 17),
        const SizedBox(width: 3),
        Text(
          store.hasRating
              ? store.rating.toStringAsFixed(1)
              : l10n.translate('store_new'),
          style: AppTextStyles.sfarabicBold.copyWith(
            fontSize: 12.5,
            color: AppColors.gray80,
          ),
        ),
        if (store.hasRating) ...[
          const SizedBox(width: 3),
          Text(
            '(${store.ratingCount})',
            style: AppTextStyles.poppinsRegular.copyWith(
              fontSize: 10.5,
              color: AppColors.gray50,
            ),
          ),
        ],
      ],
    );
  }
}

class _StoreDetails extends StatelessWidget {
  const _StoreDetails({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final workingHours = (store.workingHours ?? '').trim();
    final details = <_DetailData>[
      if (workingHours.isNotEmpty)
        _DetailData(
          AppIcons.workingHours,
          l10n.translate('store_working_hours'),
          workingHours,
          AppColors.blueCardBackgourd,
        ),
      if (store.minOrderTotal > 0)
        _DetailData(
          AppIcons.minOrder,
          l10n.translate('store_min_order'),
          '${store.minOrderTotal.toStringAsFixed(0)} ₪',
          AppColors.purbleCardBackgourd,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < details.length; index++) ...[
          _DetailTile(data: details[index]),
          if (index != details.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.data});

  final _DetailData data;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${data.label}: ${data.value}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: data.background,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(data.icon, width: 16, height: 16),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: AppTextStyles.sfarabicRegular.copyWith(
                    fontSize: 9.5,
                    color: AppColors.gray50,
                  ),
                ),
                Text(
                  data.value,
                  style: AppTextStyles.sfarabicMedium.copyWith(
                    fontSize: 11.5,
                    color: AppColors.gray80,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailData {
  const _DetailData(this.icon, this.label, this.value, this.background);

  /// مسار ملفّ SVG لا `IconData`: اللون صار في التدرّج داخل الملفّ
  /// نفسه، فلم يبقَ للون معامل يُمرَّر.
  final String icon;
  final String label;
  final String value;
  final Color background;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.background,
  });

  /// مسار SVG — الشارة تشارك لغة بقيّة أيقونات البطاقة
  final String icon;
  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(icon, width: 15, height: 15),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.sfarabicMedium.copyWith(
                fontSize: 11.5,
                color: AppColors.gray70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ما يُعرض حين لا شعار للمحل.
///
/// ★ لماذا لا حرفٌ ولا صورة عامّة ★
///
/// الحرف الأول من الاسم يجعل «مغسلة النور» و«مغسلة النجاح» بطاقتين
/// متطابقتين. وصورة مغسلة عامّة تُقرأ كأنها صورة هذا المحل فعلاً —
/// والزبون يبني عليها انطباعاً كاذباً.
///
/// فالبديل رمزٌ محايد صريح: هذا محلّ، ولا صورة له بعد. وهو بلغة أيقونات
/// التطبيق نفسها كي لا يبدو المكان معطوباً.
class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.brandSoft,
        alignment: Alignment.center,
        child: SvgPicture.asset(AppIcons.storeLogoFallback, width: 27, height: 27),
      );
}
