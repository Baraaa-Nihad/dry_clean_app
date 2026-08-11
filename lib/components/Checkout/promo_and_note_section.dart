import 'dart:convert';
import 'package:saleem_dry_clean/ui.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

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
    final localizations = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    if (order.hasPendingMeasurement) {
      setState(
        () => _error = localizations.translate(
          'promo_unavailable_price_pending',
        ),
      );
      return;
    }

    if (code.isEmpty) {
      setState(() => _error = localizations.translate('promo_code_required'));
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
        headers: {
          'Content-Type': 'application/json',
          'Accept-Language': languageCode,
        },
        body: jsonEncode({
          'code': code,
          'lang': languageCode,
          if (order.storeId != null) 'drycleanId': order.storeId,
          'subtotal': order.subtotal,
        }),
      );

      if (!mounted) return;

      dynamic body;
      try {
        body = jsonDecode(res.body);
      } catch (_) {
        body = const <String, dynamic>{};
      }

      if (res.statusCode >= 200 &&
          res.statusCode < 300 &&
          body['valid'] == true) {
        final discount = double.tryParse('${body['discount'] ?? 0}') ?? 0;
        order.applyPromo((body['code'] ?? code).toString(), discount);
        setState(() => _error = null);
        return;
      }

      // رسالة الخادم أدقّ من رسالة عامة: «الكود يصلح للطلبات من ٥٠
      // شيكل» تخبر الزبون ماذا يفعل، و«كود غير صالح» تجعله يعيد كتابته
      order.clearPromo();
      setState(
        () => _error = localizations.translate(
          _promoErrorKey(body, res.statusCode),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error = localizations.translate('server_connection_error'),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  String _promoErrorKey(dynamic body, int statusCode) {
    final code = body is Map
        ? (body['code'] ?? '').toString().trim().toUpperCase()
        : '';
    switch (code) {
      case 'CODE_REQUIRED':
        return 'promo_code_required';
      case 'SUBTOTAL_REQUIRED':
        return 'promo_empty_basket';
      case 'WRONG_STORE':
        return 'promo_wrong_laundry';
      case 'BELOW_MINIMUM':
        return 'promo_below_minimum';
      case 'CODE_EXHAUSTED':
        return 'promo_usage_limit_reached';
      case 'ALREADY_USED':
        return 'promo_already_used';
      case 'AUTH_REQUIRED':
      case 'UNAUTHORIZED':
        return 'sign_in_required_to_continue';
      case 'INVALID_CODE':
        return 'promo_code_invalid';
      default:
        if (statusCode == 401 || statusCode == 403) {
          return 'sign_in_required_to_continue';
        }
        if (statusCode >= 500) return 'unexpected_error_try_again';
        return 'promo_code_invalid';
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final applied = order.discount > 0;
    final pricePending = order.hasPendingMeasurement;
    final localizations = AppLocalizations.of(context);
    TextStyle localizedStyle(TextStyle style) =>
        AppTextStyles.getFontFamily(context, style);

    // السلّة تغيّرت بعد التطبيق ⇐ المزوّد أبطل الكود، فنُفرغ الحقل كي
    // لا يبقى معروضاً كأنه سارٍ
    if (!applied &&
        order.promoCode == null &&
        _code.text.isNotEmpty &&
        !_checking) {
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
            localizations.translate('promo_code'),
            style: localizedStyle(
              AppTextStyles.sfarabicBold.copyWith(
                fontSize: 14.5,
                color: AppColors.gray80,
              ),
            ),
          ),
          const SizedBox(height: 9),
          if (pricePending)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAF1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE3B3)),
              ),
              child: Text(
                localizations.translate('promo_unavailable_price_pending'),
                style: localizedStyle(
                  AppTextStyles.sfarabicMedium.copyWith(
                    fontSize: 12,
                    color: const Color(0xFFB97812),
                  ),
                ),
              ),
            )
          else if (applied)
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
                    style: AppTextStyles.poppinsMedium.copyWith(
                      fontSize: 14,
                      color: AppColors.gray80,
                    ),
                    decoration: InputDecoration(
                      hintText: localizations.translate('enter_promo_code'),
                      hintStyle: localizedStyle(
                        AppTextStyles.sfarabicRegular.copyWith(
                          fontSize: 13.5,
                          color: AppColors.inactiveColor,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _checking
                          ? const LinearGradient(
                              colors: [
                                AppColors.inactiveColor,
                                AppColors.inactiveColor,
                              ],
                            )
                          : const LinearGradient(
                              begin: AlignmentDirectional.centerStart,
                              end: AlignmentDirectional.centerEnd,
                              colors: [
                                AppColors.brandStart,
                                AppColors.brandEnd,
                              ],
                              stops: [0.0, 0.34],
                            ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _checking ? null : _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _checking
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              localizations.translate('apply'),
                              style: localizedStyle(
                                AppTextStyles.sfarabicBold.copyWith(
                                  fontSize: 13.5,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),

          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: localizedStyle(
                AppTextStyles.sfarabicMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.red,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          Text(
            localizations.translate('laundry_notes'),
            style: localizedStyle(
              AppTextStyles.sfarabicBold.copyWith(
                fontSize: 14.5,
                color: AppColors.gray80,
              ),
            ),
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
            style: localizedStyle(
              AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 14,
                color: AppColors.gray80,
              ),
            ),
            decoration: InputDecoration(
              hintText: localizations.translate('laundry_notes_hint'),
              hintStyle: localizedStyle(
                AppTextStyles.sfarabicRegular.copyWith(
                  fontSize: 13,
                  color: AppColors.inactiveColor,
                ),
              ),
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
            style: AppTextStyles.poppinsSemiBold.copyWith(
              fontSize: 13.5,
              color: AppColors.gray80,
            ),
          ),
        ),
        Text(
          '− ${discount.toStringAsFixed(2)}₪',
          style: AppTextStyles.poppinsSemiBold.copyWith(
            fontSize: 14,
            color: AppColors.green,
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: onRemove,
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.close,
              size: 17,
              color: AppColors.secondaryTextColor,
            ),
          ),
        ),
      ],
    ),
  );
}
