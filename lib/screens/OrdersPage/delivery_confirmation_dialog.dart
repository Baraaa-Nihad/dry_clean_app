import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

/// تأكيد استلام الطلب — زرّان لا أكثر.
///
/// ★ لماذا هذا الحوار مهمّ ★
///
/// القرار المعتمد: السائق يعلّم الطلب مسلَّماً، فيصل الزبونَ إشعارٌ
/// وبوب أب بتفاصيل الطلب وزرّان. وعلى جوابه يتوقّف شيئان: إتمام الطلب،
/// وأجرة السائق.
///
/// ولمن لا يجيب مهلة أربع وعشرين ساعة ثم تأكيد تلقائي — تتولّاها مهمة
/// خلفية في الخادم. فهذا الحوار ليس بوّابة إجبار بل فرصة اعتراض.
///
/// و«لم أستلم» ليست شكوى تُهمَل: تفتح نزاعاً تبتّ فيه الإدارة يدوياً.
Future<bool?> showDeliveryConfirmationDialog(
  BuildContext context, {
  required int orderId,
  String? orderNumber,
  String? storeName,
  double? total,
}) {
  return showDialog<bool>(
    context: context,
    // غير قابل للإغلاق بالضغط خارجه: الضغطة العابرة تُسقط سؤالاً يعلّق
    // عليه إتمام الطلب. وزرّ «لاحقاً» موجود لمن لا يريد الإجابة الآن.
    barrierDismissible: false,
    builder: (_) => _DeliveryConfirmationDialog(
      orderId: orderId,
      orderNumber: orderNumber,
      storeName: storeName,
      total: total,
    ),
  );
}

class _DeliveryConfirmationDialog extends StatefulWidget {
  const _DeliveryConfirmationDialog({
    required this.orderId,
    this.orderNumber,
    this.storeName,
    this.total,
  });

  final int orderId;
  final String? orderNumber;
  final String? storeName;
  final double? total;

  @override
  State<_DeliveryConfirmationDialog> createState() =>
      _DeliveryConfirmationDialogState();
}

class _DeliveryConfirmationDialogState
    extends State<_DeliveryConfirmationDialog> {
  bool _sending = false;
  String? _error;

  Future<void> _respond(bool received) async {
    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      final client = ApiClient.createClient(context.read<TokenService>());
      final res = await client.post(
        Uri.parse('${Config.orderTrackingApi}/${widget.orderId}/confirm-delivery'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'received': received}),
      );

      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        Navigator.pop(context, received);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: received ? AppColors.green : AppColors.orangeCard,
            content: Text(
              received
                  ? 'شكراً — سُجِّل استلامك'
                  : 'سجّلنا اعتراضك وسنتواصل معك',
              style: AppTextStyles.sfarabicMedium
                  .copyWith(color: AppColors.white),
            ),
          ),
        );
        return;
      }

      String? message;
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['message'] is String) {
          message = body['message'] as String;
        }
      } catch (_) {}
      setState(() => _error = message ?? 'تعذّر تسجيل ردّك');
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'تعذّر الاتصال بالخادم');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 66,
              height: 66,
              decoration: const BoxDecoration(
                color: AppColors.greenCardBackgourd,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_shipping_outlined,
                  size: 32, color: AppColors.green),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'هل استلمت طلبك؟',
            textAlign: TextAlign.center,
            style: AppTextStyles.sfarabicBold
                .copyWith(fontSize: 18, color: AppColors.gray80),
          ),
          const SizedBox(height: 8),
          Text(
            'أبلغنا السائق بتسليم طلبك. أكّد استلامه لنُتِمّ العملية.',
            textAlign: TextAlign.center,
            style: AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 13, height: 1.55, color: AppColors.secondaryTextColor),
          ),
          const SizedBox(height: 16),

          // تفاصيل الطلب — القرار المعتمد: «بوب أب فيه تفاصيل الطلب».
          // بلا التفاصيل قد يؤكّد الزبون طلباً غير الذي يعنيه، وله
          // طلبان جاريان.
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _Row(
                  label: 'رقم الطلب',
                  value: widget.orderNumber ?? '#${widget.orderId}',
                ),
                if ((widget.storeName ?? '').isNotEmpty) ...[
                  const SizedBox(height: 7),
                  _Row(label: 'المغسلة', value: widget.storeName!),
                ],
                if (widget.total != null) ...[
                  const SizedBox(height: 7),
                  _Row(
                    label: 'المبلغ',
                    value: '${widget.total!.toStringAsFixed(2)}₪',
                  ),
                ],
              ],
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.sfarabicMedium
                  .copyWith(fontSize: 12.5, color: AppColors.red),
            ),
          ],

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sending ? null : () => _respond(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              disabledBackgroundColor: AppColors.inactiveColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
            child: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                : Text(
                    'نعم، استلمت طلبي',
                    style: AppTextStyles.sfarabicBold
                        .copyWith(fontSize: 15, color: AppColors.white),
                  ),
          ),
          const SizedBox(height: 9),
          OutlinedButton(
            onPressed: _sending ? null : () => _respond(false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.red),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
            child: Text(
              'لم أستلم طلبي',
              style: AppTextStyles.sfarabicMedium
                  .copyWith(fontSize: 14, color: AppColors.red),
            ),
          ),
          TextButton(
            onPressed: _sending ? null : () => Navigator.pop(context, null),
            child: Text(
              'لاحقاً',
              style: AppTextStyles.sfarabicRegular.copyWith(
                  fontSize: 13, color: AppColors.secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            label,
            style: AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 12.5, color: AppColors.secondaryTextColor),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.sfarabicMedium
                .copyWith(fontSize: 13, color: AppColors.gray80),
          ),
        ],
      );
}
