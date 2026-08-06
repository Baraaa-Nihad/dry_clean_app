import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/OrderTrackingProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

/// الإبلاغ عن تلف أو فقدان.
///
/// ★ لماذا الوصف إجباري والمبلغ اختياري ★
///
/// المطالبة يفصل فيها إنسان لا خوارزمية، والوصف هو ما يفصل به. أمّا
/// المبلغ فكثير من الزبائن لا يعرفون قيمة القطعة ولا يريدون تقديرها —
/// إلزامهم به يوقف بلاغاً صحيحاً عند حقل رقمي.
///
/// والحدّ الأدنى خمسة أحرف يوافق الخادم: أقصر منه لا يصف شيئاً، ورفضه
/// هنا يوفّر على الزبون رحلة ذهاب وإياب.
Future<void> showDamageClaimSheet(
  BuildContext context, {
  required int orderId,
  int? orderItemId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (_) =>
        _DamageClaimSheet(orderId: orderId, orderItemId: orderItemId),
  );
}

class _DamageClaimSheet extends StatefulWidget {
  const _DamageClaimSheet({required this.orderId, this.orderItemId});

  final int orderId;
  final int? orderItemId;

  @override
  State<_DamageClaimSheet> createState() => _DamageClaimSheetState();
}

class _DamageClaimSheetState extends State<_DamageClaimSheet> {
  final _description = TextEditingController();
  final _amount = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final desc = _description.text.trim();
    if (desc.length < 5) {
      setState(() => _error = 'اكتب وصفاً للضرر (٥ أحرف على الأقل)');
      return;
    }

    final raw = _amount.text.trim();
    double? amount;
    if (raw.isNotEmpty) {
      amount = double.tryParse(raw);
      if (amount == null || amount <= 0) {
        setState(() => _error = 'المبلغ غير صالح');
        return;
      }
    }

    setState(() => _error = null);

    final err = await context.read<OrderTrackingProvider>().submitClaim(
          orderId: widget.orderId,
          orderItemId: widget.orderItemId,
          description: desc,
          claimedAmount: amount,
        );

    if (!mounted) return;

    if (err != null) {
      setState(() => _error = err);
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.green,
        content: Text(
          'وصلنا بلاغك وسنراجعه',
          style: AppTextStyles.sfarabicMedium.copyWith(color: AppColors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<OrderTrackingProvider>().isSubmitting;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.errorBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.report_gmailerrorred_outlined,
                      color: AppColors.red, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الإبلاغ عن تلف أو فقدان',
                        style: AppTextStyles.sfarabicBold
                            .copyWith(fontSize: 16, color: AppColors.gray80),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'سنراجع بلاغك ونعود إليك',
                        style: AppTextStyles.sfarabicRegular.copyWith(
                            fontSize: 12,
                            color: AppColors.secondaryTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'ماذا حدث؟',
              style: AppTextStyles.sfarabicMedium
                  .copyWith(fontSize: 13.5, color: AppColors.gray80),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              maxLines: 4,
              maxLength: 1000,
              textAlign: TextAlign.start,
              style: AppTextStyles.sfarabicRegular
                  .copyWith(fontSize: 14, color: AppColors.gray80),
              decoration: InputDecoration(
                hintText: 'صف الضرر والقطعة المتضرّرة…',
                hintStyle: AppTextStyles.sfarabicRegular.copyWith(
                    fontSize: 13.5, color: AppColors.inactiveColor),
                filled: true,
                fillColor: AppColors.backgroundColor,
                contentPadding: const EdgeInsets.all(14),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'قيمة القطعة (اختياري)',
              style: AppTextStyles.sfarabicMedium
                  .copyWith(fontSize: 13.5, color: AppColors.gray80),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.start,
              style: AppTextStyles.poppinsRegular
                  .copyWith(fontSize: 14, color: AppColors.gray80),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: AppTextStyles.poppinsRegular.copyWith(
                    fontSize: 13.5, color: AppColors.inactiveColor),
                suffixText: '₪',
                suffixStyle: AppTextStyles.poppinsMedium.copyWith(
                    fontSize: 13.5, color: AppColors.secondaryTextColor),
                filled: true,
                fillColor: AppColors.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.errorBorder),
                ),
                child: Text(
                  _error!,
                  style: AppTextStyles.sfarabicMedium
                      .copyWith(fontSize: 12.5, color: AppColors.red),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                disabledBackgroundColor: AppColors.inactiveColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
              ),
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    )
                  : Text(
                      'إرسال البلاغ',
                      style: AppTextStyles.sfarabicBold
                          .copyWith(fontSize: 15, color: AppColors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
