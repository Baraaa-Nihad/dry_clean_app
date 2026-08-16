import 'package:saleem_dry_clean/ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/theme/AppIcons.dart';

/// صفّ نجوم التقييم — عرضاً وإدخالاً.
///
/// ★ لماذا مكوّن واحد ★
///
/// كان الصفّ مكتوباً أربع مرّات: في ورقة التقييم، وفي «تقييماتي»، وفي
/// تقييمات صفحة المحل، وفي بطاقة السائق. أربع نسخ بأربعة أحجام وأربعة
/// ألوان — وأي تعديل يصيب واحدة ويترك ثلاثاً.
///
/// ★ والفرق بين العرض والإدخال ★
///
/// العرض يقبل الكسر: متوسّط ‎4.3‎ يُرسم أربع نجوم وثلث. والإدخال لا
/// يقبله: الزبون يختار عدداً صحيحاً من واحد إلى خمسة.
///
/// فالمكوّن واحد و[onRate] هو الفارق: بوجودها يصير الصفّ قابلاً للضغط
/// ويُقرَّب إلى الصحيح، وبغيابها يعرض ما وصل كما وصل.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.score,
    this.size = 17,
    this.gap = 2,
    this.onRate,
  });

  /// من ٠ إلى ٥ — يُحدّ داخلياً فلا يكسر الصفّ رقمٌ شاذّ من الخادم
  final double score;
  final double size;
  final double gap;

  /// حين تُمرَّر يصير الصفّ أداة اختيار لا عرضاً
  final ValueChanged<int>? onRate;

  bool get _interactive => onRate != null;

  /// ★ لماذا عتبة ٠٫٢٥ و٠٫٧٥ لا ٠٫٥ وحدها ★
  ///
  /// ‎4.1‎ ليس أربعاً ونصفاً، و‎4.9‎ ليس كذلك. فالثلث الأدنى يُقرَّب إلى
  /// فارغة والأعلى إلى ممتلئة، وما بينهما وحده نصف. وبذلك تصدق الصورة
  /// بدل أن تُجمّل.
  String _iconFor(int index) {
    final value = score.clamp(0, 5).toDouble();
    final remainder = value - index;
    if (remainder >= 0.75) return AppIcons.ratingStar;
    if (remainder >= 0.25) return AppIcons.ratingStarHalf;
    return AppIcons.ratingStarOutline;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final star = SvgPicture.asset(
          // الإدخال لا نصف فيه: الضغط على الثالثة يعني ثلاثاً
          _interactive
              ? (index < score.round()
                  ? AppIcons.ratingStar
                  : AppIcons.ratingStarOutline)
              : _iconFor(index),
          width: size,
          height: size,
        );

        final padded = Padding(
          padding: EdgeInsets.symmetric(horizontal: gap),
          child: star,
        );

        if (!_interactive) return padded;

        return InkResponse(
          onTap: () => onRate!(index + 1),
          radius: size,
          // مساحة اللمس أوسع من النجمة: نجمة ‎17‎ بكسل مقصد صغير على
          // إصبع، فيضغط الزبون بين نجمتين ولا يقع شيء
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: gap, vertical: 4),
            child: star,
          ),
        );
      }),
    );
  }
}
