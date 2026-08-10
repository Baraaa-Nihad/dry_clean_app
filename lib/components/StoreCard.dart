import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/store_localization.dart';

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
                            icon: Icons.local_offer_outlined,
                            label: l10n.translate('store_offer_available'),
                            color: AppColors.orangeCard,
                            background: AppColors.orangeCardBackgourd,
                          ),
                        if (disabled)
                          _StatusPill(
                            icon: Icons.info_outline_rounded,
                            label: l10n.translate('store_pricing_unavailable'),
                            color: AppColors.orangeCard,
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
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _StoreLogo(store: store),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
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
                  if (store.isPromoted) ...[
                    const SizedBox(width: 7),
                    _MiniLabel(
                      icon: Icons.workspace_premium_outlined,
                      label: l10n.translate('store_featured'),
                    ),
                  ],
                ],
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
                  child: Icon(
                    store.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: store.isFavorite ? AppColors.red : AppColors.gray50,
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
        const Icon(Icons.star_rounded, size: 18, color: AppColors.orangeCard),
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
    final turnaround = localizedTurnaround(context, store.turnaroundHours);
    final details = <_DetailData>[
      if (turnaround.isNotEmpty)
        _DetailData(
          Icons.schedule_outlined,
          l10n.translate('store_turnaround'),
          turnaround,
          AppColors.blueCard,
          AppColors.blueCardBackgourd,
        ),
      if (store.minOrderTotal > 0)
        _DetailData(
          Icons.account_balance_wallet_outlined,
          l10n.translate('store_min_order'),
          '${store.minOrderTotal.toStringAsFixed(0)} ₪',
          AppColors.prpuleCard,
          AppColors.purbleCardBackgourd,
        ),
      if (store.productsCount > 0)
        _DetailData(
          Icons.local_laundry_service_outlined,
          l10n.translate('store_services_available'),
          l10n.translate(
            'store_services_count',
            params: {'count': '${store.productsCount}'},
          ),
          AppColors.greenCard,
          AppColors.greenCardBackgourd,
        ),
      if (store.averagePrice != null)
        _DetailData(
          Icons.payments_outlined,
          l10n.translate('store_average_price'),
          '${store.averagePrice!.toStringAsFixed(0)} ₪',
          AppColors.orangeCard,
          AppColors.orangeCardBackgourd,
        ),
    ];

    final working = (store.workingHours ?? '').trim();
    final numericWorking = RegExp(r'^\d+(\.\d+)?$').hasMatch(working);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 330;
        final itemWidth =
            compact ? constraints.maxWidth : (constraints.maxWidth - 10) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 11,
              children: details
                  .map((detail) => SizedBox(
                        width: itemWidth,
                        child: _DetailTile(data: detail),
                      ))
                  .toList(),
            ),
            if (working.isNotEmpty) ...[
              const SizedBox(height: 11),
              _DetailTile(
                data: _DetailData(
                  numericWorking
                      ? Icons.hourglass_bottom_rounded
                      : Icons.access_time_rounded,
                  numericWorking
                      ? l10n.translate('store_processing_time')
                      : l10n.translate('store_working_hours'),
                  numericWorking
                      ? l10n.translate(
                          'duration_hours',
                          params: {'count': working},
                        )
                      : working,
                  AppColors.gray60,
                  AppColors.gray10,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.data});

  final _DetailData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: data.background,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(data.icon, size: 18, color: data.color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sfarabicRegular.copyWith(
                  fontSize: 10.5,
                  color: AppColors.gray50,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                data.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sfarabicMedium.copyWith(
                  fontSize: 12.5,
                  color: AppColors.gray80,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailData {
  const _DetailData(
    this.icon,
    this.label,
    this.value,
    this.color,
    this.background,
  );

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.blueCardBackgourd,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.blueCard),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.sfarabicMedium.copyWith(
              fontSize: 10.5,
              color: AppColors.gray70,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
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
          Icon(icon, size: 16, color: color),
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
