import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

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
    final disabled = !store.canOrder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Opacity(
        // المحل بلا أصناف يُعرض باهتاً لا مخفياً: إخفاؤه يجعل الزبون
        // يسأل «أين المحل الذي رأيته أمس»
        opacity: disabled ? 0.55 : 1,
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: disabled ? null : onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CoverStrip(store: store, onFavoriteTap: onFavoriteTap),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.sfarabicBold.copyWith(
                                fontSize: 16,
                                color: AppColors.gray80,
                              ),
                            ),
                          ),
                          if (store.hasRating) _RatingChip(store: store),
                        ],
                      ),
                      if ((store.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          store.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.sfarabicRegular.copyWith(
                            fontSize: 12.5,
                            height: 1.5,
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      _MetaRow(store: store),
                      if (disabled) ...[
                        const SizedBox(height: 10),
                        Text(
                          'لم يضبط هذا المحل أسعاره بعد',
                          style: AppTextStyles.sfarabicMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.orangeCard,
                          ),
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

/// شريط الغلاف مع الشعار والشارات.
///
/// الغلاف غير موجود لمعظم المحلات بعد، فالبديل تدرّج الهوية لا صورة
/// رمادية: التدرّج يبدو مقصوداً والرمادي يبدو عطلاً.
class _CoverStrip extends StatelessWidget {
  const _CoverStrip({required this.store, this.onFavoriteTap});

  final Store store;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if ((store.coverUrl ?? '').isNotEmpty)
            Image.network(
              store.coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _GradientCover(),
            )
          else
            const _GradientCover(),

          // تعتيم خفيف يضمن قراءة الشارات فوق أي صورة
          Container(
            // ملاحظة: withOpacity مُهمَل في Flutter الأحدث، لكن withValues
            // غير موجود في الإصدار الذي يستعمله هذا التطبيق. يُستبدل عند
            // ترقية Flutter لا قبلها.
            // ignore: deprecated_member_use
            color: AppColors.black.withOpacity(0.12),
          ),

          // الشعار
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadowColor, blurRadius: 8),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: (store.logoUrl ?? '').isNotEmpty
                  ? Image.network(
                      store.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _LogoFallback(),
                    )
                  : const _LogoFallback(),
            ),
          ),

          if (store.hasActiveOffer)
            Positioned(
              top: 12,
              left: 12,
              child: _Badge(
                label: 'عرض',
                color: AppColors.red,
                icon: Icons.local_offer_outlined,
              ),
            ),

          if (store.isPromoted)
            Positioned(
              bottom: 10,
              left: 12,
              child: _Badge(
                label: 'مميّز',
                color: AppColors.orangeCard,
                icon: Icons.star_rounded,
              ),
            ),

          Positioned(
            bottom: 8,
            right: 8,
            child: Material(
              color: AppColors.white,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onFavoriteTap,
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(
                    store.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 19,
                    color: store.isFavorite
                        ? AppColors.red
                        : AppColors.secondaryTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientCover extends StatelessWidget {
  const _GradientCover();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.gradient),
      );
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.blueCardBackgourd,
        alignment: Alignment.center,
        child: const Icon(Icons.local_laundry_service_outlined,
            size: 26, color: AppColors.blueCard),
      );
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.store});
  final Store store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.greenCardBackgourd,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, size: 15, color: AppColors.greenCard),
          const SizedBox(width: 3),
          Text(
            store.rating.toStringAsFixed(1),
            style: AppTextStyles.poppinsSemiBold.copyWith(
              fontSize: 12.5,
              color: AppColors.gray80,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '(${store.ratingCount})',
            style: AppTextStyles.poppinsRegular.copyWith(
              fontSize: 11,
              color: AppColors.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// سطر البيانات: مدّة التجهيز · الحدّ الأدنى · متوسّط السعر
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.store});
  final Store store;

  @override
  Widget build(BuildContext context) {
    // ★ صنف صغير لا سجلّ ★
    //
    // التطبيق على Dart 2.19 ولا يدعم السجلّات (records). رفع الإصدار
    // لأجل ثلاثة أسطر يعني إعادة فحص 247 ملفاً، فالصنف أرخص.
    final items = <_MetaItem>[
      if (store.turnaroundLabel != null)
        _MetaItem(Icons.schedule, store.turnaroundLabel!),
      if (store.minOrderTotal > 0)
        _MetaItem(Icons.shopping_bag_outlined,
            'أقلّ طلب ${store.minOrderTotal.toStringAsFixed(0)}₪'),
      if (store.averagePrice != null)
        _MetaItem(Icons.sell_outlined,
            'متوسّط ${store.averagePrice!.toStringAsFixed(0)}₪'),
      // ساعات العمل (٢.١.٢) — آخر السطر لأنها الأطول نصّاً
      if ((store.workingHours ?? '').isNotEmpty)
        _MetaItem(Icons.access_time, store.workingHours!),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: items
          .map((e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(e.icon, size: 15, color: AppColors.secondaryTextColor),
                  const SizedBox(width: 4),
                  Text(
                    e.label,
                    style: AppTextStyles.sfarabicMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }
}

class _MetaItem {
  const _MetaItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.sfarabicBold.copyWith(
              fontSize: 11.5,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
