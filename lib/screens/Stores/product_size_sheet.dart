import 'package:saleem_dry_clean/ui.dart';
import 'package:flutter/services.dart';
import 'package:saleem_dry_clean/services/Models/StoreProduct.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/store_localization.dart';

/// اختيار مساحة الصنف المسعَّر بالمتر المربّع.
///
/// ★ لماذا مقاسات جاهزة ومقاس حرّ معاً ★
///
/// معظم السجاجيد بمقاسات معروفة، واختيارها بضغطة أسرع وأدقّ من كتابة
/// رقمين. لكن المقاسات الجاهزة لا تغطّي كل بيت، ومن لا يجد مقاسه يحتاج
/// مخرجاً — وإلّا امتنع عن الطلب.
///
/// ما قاسه الزبون: مساحةٌ ومعها بُعداها إن عُرفا.
///
/// ★ لماذا لا تكفي المساحة ★
///
/// الفاتورة تُحسب بالمساحة، لكن المحل يستلم سجادةً يقيسها ليتحقّق.
/// و«ستّة أمتار» لا تُراجَع: أهي ٢×٣ أم ١×٦؟ فالبُعدان يُحفظان مع
/// الطلب متى عُرفا، وتبقى المساحة وحدها لمن اختار مقاساً جاهزاً لا
/// أبعاد له.
class ProductMeasure {
  const ProductMeasure({required this.area, this.width, this.length});

  final double area;
  final double? width;
  final double? length;
}

/// تعيد قياس الزبون، أو null إن تراجع.
Future<ProductMeasure?> showProductSizeSheet(
  BuildContext context, {
  required StoreProduct product,
}) {
  return showModalBottomSheet<ProductMeasure>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    // ★ الشقّ والنقش لا يبتلعان رأس الورقة ★
    //
    // بلا هذا تبدأ الورقة من أعلى الشاشة تماماً حين يطول محتواها،
    // فيختفي مقبضها وعنوانها خلف شريط الحالة.
    //
    // وهو يحمي الأعلى وحده — والأسفل يُحسب في الورقة نفسها.
    useSafeArea: true,
    builder: (_) => _ProductSizeSheet(product: product),
  );
}

class _ProductSizeSheet extends StatefulWidget {
  const _ProductSizeSheet({required this.product});
  final StoreProduct product;

  @override
  State<_ProductSizeSheet> createState() => _ProductSizeSheetState();
}

class _ProductSizeSheetState extends State<_ProductSizeSheet> {
  ProductSize? _selected;
  bool _custom = false;

  final _width = TextEditingController();
  final _height = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    // لا اختيار مسبق: المساحة تحدّد السعر، واختيارها نيابةً عن الزبون
    // يجعله يدفع ثمن مقاس لم يقصده
    _custom = widget.product.sizes.isEmpty;
  }

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    super.dispose();
  }

  double? get _area => _measure?.area;

  /// القياس الحاليّ — من مقاسٍ جاهز أو من بُعدين مكتوبين.
  ProductMeasure? get _measure {
    if (!_custom) {
      final s = _selected;
      if (s == null) return null;
      // المقاس الجاهز يحمل بُعديه، فيُنقلان كما هما
      return ProductMeasure(area: s.area, width: s.width, length: s.height);
    }
    final w = double.tryParse(_width.text.trim());
    final h = double.tryParse(_height.text.trim());
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return ProductMeasure(area: w * h, width: w, length: h);
  }

  void _confirm() {
    final l10n = AppLocalizations.of(context);
    final measure = _measure;
    final a = measure?.area;
    if (measure == null || a == null) {
      setState(() => _error = _custom
          ? l10n.translate('size_enter_dimensions')
          : l10n.translate('size_select_first'));
      return;
    }
    if (a > 200) {
      // حدّ أعلى معقول: خطأ في الفاصلة العشرية يحوّل ٤×٦ إلى ٤٠×٦٠
      // فتصير الفاتورة بالآلاف
      setState(() => _error = l10n.translate('size_too_large'));
      return;
    }
    Navigator.pop(context, measure);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final p = widget.product;
    final area = _area;
    final total = area == null ? null : area * p.effectivePrice;

    // ★ الأسفل مسافتان لا واحدة ★
    //
    // لوحة المفاتيح حين تُفتح، وشريط الإيماءات حين تُغلق. وأخذُ
    // الأولى وحدها — وهو ما كان — يترك الزرّ تحت شريط الإيماءات:
    // يُرى نصفه ولا يُضغط.
    //
    // ولا تُجمعان: المفتوحة تغطّي الشريط، فجمعُهما يرفع الزرّ عن
    // موضعه بلا داعٍ.
    final keyboard = media.viewInsets.bottom;
    final gesture = media.viewPadding.bottom;
    final bottomGap = (keyboard > 0 ? keyboard : gesture) + 22;

    return ConstrainedBox(
      // ★ سقفٌ دون الشاشة ★
      //
      // ورقةٌ تملأ الشاشة تبدو صفحةً لا ورقة، فيبحث الزبون عن زرّ
      // رجوعٍ ليس فيها. والفجوة فوقها تقول: اسحبني أو المسني لأزول.
      constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── الرأس: ثابت ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.stroke,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    localizedCatalogValue(context, p.name),
                    style: AppTextStyles.sfarabicBold
                        .copyWith(fontSize: 17, color: AppColors.gray80),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.translate(
                      'size_priced_per_sqm',
                      params: {'price': p.effectivePrice.toStringAsFixed(2)},
                    ),
                    style: AppTextStyles.sfarabicRegular.copyWith(
                        fontSize: 12.5, color: AppColors.secondaryTextColor),
                  ),
                ],
              ),
            ),

            // ── الوسط: هو وحده الذي يمرّ ──
            //
            // ★ Flexible لا Expanded ★
            //
            // سجادةٌ بمقاسين لا تستحقّ ورقةً تملأ الشاشة. و`Flexible`
            // يأخذ قدر المحتوى ولا يزيد، ولا يتمدّد إلّا عند الحاجة.
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (p.sizes.isNotEmpty) ...[
                      Text(
                        l10n.translate('size_choose'),
                        style: AppTextStyles.sfarabicMedium
                            .copyWith(fontSize: 13.5, color: AppColors.gray80),
                      ),
                      const SizedBox(height: 10),
                      ...p.sizes.map((s) => _SizeRow(
                            size: s,
                            pricePerMeter: p.effectivePrice,
                            selected: !_custom && _selected == s,
                            onTap: () => setState(() {
                              _selected = s;
                              _custom = false;
                              _error = null;
                            }),
                          )),
                      const SizedBox(height: 6),
                      _CustomToggle(
                        active: _custom,
                        onTap: () => setState(() {
                          _custom = true;
                          _selected = null;
                          _error = null;
                        }),
                      ),
                    ],
                    if (_custom) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _DimField(
                              controller: _width,
                              label: l10n.translate('size_width_m'),
                              onChanged: (_) => setState(() => _error = null),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DimField(
                              controller: _height,
                              label: l10n.translate('size_length_m'),
                              onChanged: (_) => setState(() => _error = null),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── القدم: المبلغ والزرّ، لا يغيبان مهما طالت المقاسات ──
            //
            // ★ لماذا خرجا من المِمرّ ★
            //
            // كانا في آخره، فمن فتح ورقةً بعشرة مقاسات لا يرى زرّ
            // الإضافة حتى ينزل إلى قاعها — ولا شيء يدلّه أن تحتها
            // شيئاً. والسعر معه: يُقرأ لحظة الضغط لا قبله بشاشة.
            Padding(
              padding: EdgeInsets.fromLTRB(22, 14, 22, bottomGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (total != null) ...[
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.brandSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${area!.toStringAsFixed(2)} ${l10n.translate('unit_square_meter_short')}',
                            style: AppTextStyles.poppinsMedium.copyWith(
                                fontSize: 13,
                                color: AppColors.secondaryTextColor),
                          ),
                          const Spacer(),
                          Text(
                            '${total.toStringAsFixed(2)}₪',
                            style: AppTextStyles.poppinsSemiBold.copyWith(
                                fontSize: 16, color: AppColors.brandAccent),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: AppTextStyles.sfarabicMedium
                          .copyWith(fontSize: 12.5, color: AppColors.red),
                    ),
                    const SizedBox(height: 12),
                  ],
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: ElevatedButton(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.transparent,
                        shadowColor: AppColors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(
                        l10n.translate('size_add_to_basket'),
                        style: AppTextStyles.sfarabicBold
                            .copyWith(fontSize: 15, color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeRow extends StatelessWidget {
  const _SizeRow({
    required this.size,
    required this.pricePerMeter,
    required this.selected,
    required this.onTap,
  });

  final ProductSize size;
  final double pricePerMeter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppColors.brandSoft : AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 19,
                  color: selected
                      ? AppColors.brandAccent
                      : AppColors.inactiveColor,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    localizedProductSize(context, size),
                    style: AppTextStyles.sfarabicMedium
                        .copyWith(fontSize: 13.5, color: AppColors.gray80),
                  ),
                ),
                // السعر بجانب كل مقاس: المفاضلة بين المقاسات مفاضلة
                // بين أسعار، وإخفاؤها يجعل الزبون يخمّن
                Text(
                  '${(size.area * pricePerMeter).toStringAsFixed(0)}₪',
                  style: AppTextStyles.poppinsSemiBold.copyWith(
                    fontSize: 13,
                    color: selected ? AppColors.brandAccent : AppColors.gray60,
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

class _CustomToggle extends StatelessWidget {
  const _CustomToggle({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.straighten,
            size: 17,
            color:
                active ? AppColors.brandAccent : AppColors.secondaryTextColor),
        label: Text(
          l10n.translate('size_other'),
          style: AppTextStyles.sfarabicMedium.copyWith(
            fontSize: 13,
            color:
                active ? AppColors.brandAccent : AppColors.secondaryTextColor,
          ),
        ),
      ),
    );
  }
}

class _DimField extends StatelessWidget {
  const _DimField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // الأرقام والفاصلة العشرية فقط: حرف واحد يجعل double.tryParse
      // يعيد null فيبدو الحقل معطّلاً بلا سبب ظاهر
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      textAlign: TextAlign.center,
      style: AppTextStyles.poppinsMedium
          .copyWith(fontSize: 15, color: AppColors.gray80),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.sfarabicRegular
            .copyWith(fontSize: 12.5, color: AppColors.secondaryTextColor),
        filled: true,
        fillColor: AppColors.backgroundColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
