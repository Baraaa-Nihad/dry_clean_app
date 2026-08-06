import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

/// كود الخصم وملاحظة الزبون في ملخّص الطلب (٢.١.٤).
///
/// ★ التحقّق لا الاستهلاك ★
///
/// الضغط على «تطبيق» ينادي مساراً يتحقّق ويحسب القيمة، ولا يستهلك
/// الكود. والاستهلاك يقع في الخادم داخل معاملة الطلب — فزبون يتحقّق من
/// كوده عشر مرّات ثم يترك التطبيق لا يخسر استعمالاً.
class PromoAndNoteSection extends StatefulWidget {
  const PromoAndNoteSection({super.key});

  @override
  State<PromoAndNoteSection> createState() => _PromoAndNoteSectionState();
}

class _PromoAndNoteSectionState extends State<PromoAndNoteSection> {
  final _code = TextEditingController();
  final _note = TextEditingController();

  bool _checking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final order = context.read<OrderProvider>();
    _code.text = order.promoCode ?? '';
    _note.text = order.customerNote;
  }

  @override
  void dispose() {
    _code.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final order = context.read<OrderProvider>();
    final code = _code.text.trim();

    if (code.isEmpty) {
      setState(() => _error = 'أدخل كود الخصم');
      return;
    }

    setState(() {
      _checking = true;
      _error = null;
    });

    try {
      final client = ApiClient.createClient(context.read<TokenService>());
      final res = await client.post(
        Uri.parse(Config.validatePromoApi),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          if (order.storeId != null) 'drycleanId': order.storeId,
          'subtotal': order.subtotal,
        }),
      );

      if (!mounted) return;

      final body = jsonDecode(res.body);

      if (res.statusCode >= 200 && res.statusCode < 300 && body['valid'] == true) {
        final discount = double.tryParse('${body['discount'] ?? 0}') ?? 0;
        order.applyPromo((body['code'] ?? code).toString(), discount);
        setState(() => _error = null);
        return;
      }

      // رسالة الخادم أدقّ من رسالة عامة: «الكود يصلح للطلبات من ٥٠
      // شيكل» تخبر الزبون ماذا يفعل، و«كود غير صالح» تجعله يعيد كتابته
      order.clearPromo();
      setState(() => _error =
          (body is Map && body['message'] is String)
              ? body['message'] as String
              : 'كود الخصم غير صالح');
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'تعذّر الاتصال بالخادم');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final applied = order.discount > 0;

    // السلّة تغيّرت بعد التطبيق ⇐ المزوّد أبطل الكود، فنُفرغ الحقل كي
    // لا يبقى معروضاً كأنه سارٍ
    if (!applied && order.promoCode == null && _code.text.isNotEmpty && !_checking) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && order.promoCode == null) _code.clear();
      });
    }

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'كود الخصم',
            style: AppTextStyles.sfarabicBold
                .copyWith(fontSize: 14.5, color: AppColors.gray80),
          ),
          const SizedBox(height: 9),
          if (applied)
            _AppliedRow(
              code: order.promoCode ?? '',
              discount: order.discount,
              onRemove: () {
                order.clearPromo();
                _code.clear();
                setState(() => _error = null);
              },
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _code,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.poppinsMedium
                        .copyWith(fontSize: 14, color: AppColors.gray80),
                    decoration: InputDecoration(
                      hintText: 'أدخل الكود',
                      hintStyle: AppTextStyles.sfarabicRegular.copyWith(
                          fontSize: 13.5, color: AppColors.inactiveColor),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _checking ? null : _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      disabledBackgroundColor: AppColors.inactiveColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _checking
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.white),
                          )
                        : Text(
                            'تطبيق',
                            style: AppTextStyles.sfarabicBold.copyWith(
                                fontSize: 13.5, color: AppColors.white),
                          ),
                  ),
                ),
              ],
            ),

          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTextStyles.sfarabicMedium
                  .copyWith(fontSize: 12, color: AppColors.red),
            ),
          ],

          const SizedBox(height: 20),
          Text(
            'ملاحظات للمغسلة',
            style: AppTextStyles.sfarabicBold
                .copyWith(fontSize: 14.5, color: AppColors.gray80),
          ),
          const SizedBox(height: 9),
          TextField(
            controller: _note,
            maxLines: 3,
            maxLength: 500,
            textAlign: TextAlign.start,
            // تُحفظ عند كل حرف لا عند زرّ: لا زرّ حفظ في الشاشة،
            // والزبون ينتقل إلى الدفع مباشرة
            onChanged: order.setCustomerNote,
            style: AppTextStyles.sfarabicRegular
                .copyWith(fontSize: 14, color: AppColors.gray80),
            decoration: InputDecoration(
              hintText: 'مثلاً: اتصل بي قبل الوصول، أو بقعة على الياقة',
              hintStyle: AppTextStyles.sfarabicRegular
                  .copyWith(fontSize: 13, color: AppColors.inactiveColor),
              filled: true,
              fillColor: AppColors.backgroundColor,
              contentPadding: const EdgeInsets.all(14),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppliedRow extends StatelessWidget {
  const _AppliedRow({
    required this.code,
    required this.discount,
    required this.onRemove,
  });

  final String code;
  final double discount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.greenCardBackgourd,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 19, color: AppColors.green),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                code,
                style: AppTextStyles.poppinsSemiBold
                    .copyWith(fontSize: 13.5, color: AppColors.gray80),
              ),
            ),
            Text(
              '− ${discount.toStringAsFixed(2)}₪',
              style: AppTextStyles.poppinsSemiBold
                  .copyWith(fontSize: 14, color: AppColors.green),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close,
                    size: 17, color: AppColors.secondaryTextColor),
              ),
            ),
          ],
        ),
      );
}
