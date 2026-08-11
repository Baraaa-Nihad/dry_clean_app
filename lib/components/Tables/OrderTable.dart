import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/store_localization.dart';

/// جدول بنود الإيصال.
///
/// إذا احتوى الطلب على سجادة بقياس غير معروف، فلا نعرض أي مبلغ في الجدول
/// حتى لا يوحي ذلك بأن السعر النهائي تم احتسابه قبل قياسها.
class OrderTable extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final bool pricePending;

  const OrderTable({
    super.key,
    required this.title,
    required this.items,
    this.pricePending = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              localizedCatalogValue(context, title),
              style: _textStyle(
                context,
                fontSize: 16,
                weight: FontWeight.w600,
                color: AppColors.gray80,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5EAF6), width: .5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5EAF6), width: .5),
                    ),
                  ),
                  child: _tableRow(
                    context,
                    item: _headerCell(context, l10n.translate('itemsTitle')),
                    quantity: _headerCell(context, l10n.translate('Qty')),
                    price: pricePending
                        ? null
                        : _headerCell(context, l10n.translate('price')),
                    total: pricePending
                        ? null
                        : _headerCell(context, l10n.translate('Total')),
                  ),
                ),
                ...items.map((item) => _itemRow(context, item)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(BuildContext context, Map<String, dynamic> item) {
    final l10n = AppLocalizations.of(context);
    final name = localizedCatalogValue(context, item['name']?.toString() ?? '');
    final quantity = _asInt(item['qty']);
    final price = _asDouble(item['price']);
    // `total` comes from the server and includes square-meter area.  Do not
    // derive it from price × quantity: that is incorrect for carpets.
    final total = item.containsKey('total') ? _asDouble(item['total']) : price * quantity;

    // ★ القياس المعلَّق سطرٌ سطر ★
    //
    // العلم على مستوى الصنف لا الطلب: سجادة قاسها الزبون وأخرى لم
    // يقسها في الطلب نفسه — إخفاء السعرين معاً يخفي رقماً معلوماً،
    // وإظهارهما معاً يطبع «٠٫٠٠» لما لم يُقَس فيقرأ كأنه مجّاني.
    final itemPending = item['measurementPending'] == true;
    final pendingLabel = l10n.translate('price_after_processing');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: _tableRow(
        context,
        item: _itemCell(context, name, textAlign: TextAlign.start),
        quantity: _itemCell(context, '$quantity', textAlign: TextAlign.end),
        price: pricePending
            ? null
            : _itemCell(
                context,
                itemPending ? '—' : '₪${price.toStringAsFixed(2)}',
                textAlign: TextAlign.end,
              ),
        total: pricePending
            ? null
            : _itemCell(
                context,
                itemPending ? pendingLabel : '₪${total.toStringAsFixed(2)}',
                textAlign: TextAlign.end,
              ),
      ),
    );
  }

  Widget _tableRow(
    BuildContext context, {
    required Widget item,
    required Widget quantity,
    Widget? price,
    Widget? total,
  }) {
    final showPrices = price != null && total != null;
    return Row(
      children: [
        Expanded(flex: showPrices ? 5 : 1, child: item),
        if (showPrices) ...[
          const SizedBox(width: 8),
          SizedBox(width: 58, child: price),
        ],
        const SizedBox(width: 8),
        SizedBox(width: 34, child: quantity),
        if (showPrices) ...[
          const SizedBox(width: 8),
          SizedBox(width: 58, child: total),
        ],
      ],
    );
  }

  Widget _headerCell(BuildContext context, String text) => Text(
        text,
        textAlign: TextAlign.end,
        style: _textStyle(
          context,
          fontSize: 14,
          weight: FontWeight.w500,
          color: AppColors.gray80,
        ),
      );

  Widget _itemCell(BuildContext context, String text,
          {required TextAlign textAlign}) =>
      Text(
        text,
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _textStyle(
          context,
          fontSize: 14,
          weight: FontWeight.w400,
          color: AppColors.gray70,
        ),
      );

  TextStyle _textStyle(
    BuildContext context, {
    required double fontSize,
    required FontWeight weight,
    required Color color,
  }) {
    final base = AppTextStyles.regular16Gray80(context);
    return AppTextStyles.getFontFamily(
      context,
      base.copyWith(fontSize: fontSize, fontWeight: weight, color: color),
    );
  }

  int _asInt(dynamic value) => value is int
      ? value
      : int.tryParse(value?.toString() ?? '') ?? 0;

  double _asDouble(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;
}
