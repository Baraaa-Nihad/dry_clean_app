import 'package:saleem_dry_clean/ui.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Rating/RatingStars.dart';
import 'package:saleem_dry_clean/services/Models/OrderTracking.dart';
import 'package:saleem_dry_clean/services/Providers/OrderTrackingProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

/// ورقة تقييم جهة واحدة.
///
/// ★ لماذا ورقة لا شاشة ★
///
/// التقييم فعل من خطوتين — نجوم وتعليق اختياري — ويقع وسط تصفّح الطلب.
/// دفع الزبون إلى شاشة كاملة يقطع سياقه ويجعل الرجوع خطوة إضافية.
///
/// وorderId هنا لا الجهة وحدها: الخادم يربط التقييم بالطلب كي يمنع
/// تقييم المحل الواحد ألف مرة من زبون واحد.
Future<void> showRatingSheet(
  BuildContext context, {
  required int orderId,
  required RatableTarget target,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (_) => _RatingSheet(orderId: orderId, target: target),
  );
}

class _RatingSheet extends StatefulWidget {
  const _RatingSheet({required this.orderId, required this.target});

  final int orderId;
  final RatableTarget target;

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _score = 0;
  final _comment = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_score == 0) {
      setState(() => _error = 'اختر عدد النجوم أولاً');
      return;
    }
    setState(() => _error = null);

    final err = await context.read<OrderTrackingProvider>().submitRating(
          orderId: widget.orderId,
          targetType: widget.target.type,
          score: _score,
          comment: _comment.text,
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
          'شكراً لتقييمك',
          style: AppTextStyles.sfarabicMedium.copyWith(color: AppColors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<OrderTrackingProvider>().isSubmitting;

    return Padding(
      // الإزاحة بارتفاع لوحة المفاتيح: حقل التعليق أسفل الورقة، وبدونها
      // تغطّيه اللوحة تماماً
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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
            Text(
              widget.target.label,
              textAlign: TextAlign.center,
              style: AppTextStyles.sfarabicBold
                  .copyWith(fontSize: 17, color: AppColors.gray80),
            ),
            const SizedBox(height: 5),
            Text(
              widget.target.question,
              textAlign: TextAlign.center,
              style: AppTextStyles.sfarabicRegular.copyWith(
                  fontSize: 13, color: AppColors.secondaryTextColor),
            ),
            const SizedBox(height: 20),
            _Stars(score: _score, onChanged: (v) => setState(() => _score = v)),
            if (_score > 0) ...[
              const SizedBox(height: 8),
              Text(
                _labelFor(_score),
                textAlign: TextAlign.center,
                style: AppTextStyles.sfarabicMedium
                    .copyWith(fontSize: 13, color: AppColors.green),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _comment,
              maxLines: 3,
              maxLength: 500,
              textAlign: TextAlign.start,
              style: AppTextStyles.sfarabicRegular
                  .copyWith(fontSize: 14, color: AppColors.gray80),
              decoration: InputDecoration(
                hintText: 'أضف تعليقاً (اختياري)',
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
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.sfarabicMedium
                    .copyWith(fontSize: 12.5, color: AppColors.red),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
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
                      'إرسال التقييم',
                      style: AppTextStyles.sfarabicBold
                          .copyWith(fontSize: 15, color: AppColors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(int score) {
    switch (score) {
      case 1:
        return 'سيّئ';
      case 2:
        return 'مقبول';
      case 3:
        return 'جيّد';
      case 4:
        return 'جيّد جداً';
      default:
        return 'ممتاز';
    }
  }
}

/// النجوم الخمس.
///
/// الترتيب من اليمين لليسار صراحةً: الواجهة عربية، والنجمة الأولى يجب
/// أن تكون أقصى اليمين مهما كان اتجاه المحيط.
class _Stars extends StatelessWidget {
  const _Stars({required this.score, required this.onChanged});

  final int score;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // النجوم تُملأ من اليمين في العربية: الأولى هي أوّل ما تراه العين
    return Center(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: RatingStars(
          score: score.toDouble(),
          size: 36,
          gap: 3,
          onRate: onChanged,
        ),
      ),
    );
  }
}
