/// فهرس أيقونات سليم.
///
/// ★ لماذا مصدر واحد ★
///
/// النجمة نفسها تظهر في بطاقة المحل وفي صفحته، والقلب في البطاقة وفي
/// فلتر المفضّلة وفي شاشة المفضّلة الفارغة. ومسارٌ مكتوب في أربعة ملفات
/// يتباعد عند أول تعديل: تُبدَّل واحدة وتبقى ثلاث.
///
/// ★ ولغة الرسم واحدة ★
///
/// كلّها بخطّ ‎1.5‎ وتدرّج العلامة ‎#00E213 → #01B5CF‎، وهي لغة أيقونات
/// صفحة الحساب. واللون داخل الملفّ لا معاملاً يُمرَّر — فلا يستطيع
/// موضعٌ أن يشذّ بلون خاص.
class AppIcons {
  const AppIcons._();

  // ── التقييم ──
  //
  // ثلاث حالات: ممتلئة وفارغة ونصفية. والثلاث تخدم العرض والإدخال معاً
  // — كانت شاشات الإدخال على نجوم ذهبية من Material، فتبدو أداةً من
  // تطبيق آخر داخل تطبيقنا.
  static const ratingStar = 'assets/Icons/storeRatingStar.svg';
  static const ratingStarOutline = 'assets/Icons/storeRatingStarOutline.svg';

  /// نصف نجمة — الحشو مقصوص عند المنتصف والحدّ كامل.
  ///
  /// تلزم لعرض متوسّط كسريّ: تقييم ‎4.3‎ بأربع نجوم يكذب بنقصان، وبخمس
  /// يكذب بزيادة. والنصف يقول الحقيقة بلا رقم.
  static const ratingStarHalf = 'assets/Icons/storeRatingStarHalf.svg';

  // ── المفضّلة ──
  //
  // شكل واحد بحالتين، فلا يتعلّم الزبون أيقونتين لمعنى واحد.
  static const heart = 'assets/Icons/storeFavoriteHeart.svg';
  static const heartFilled = 'assets/Icons/storeFavoriteHeartFilled.svg';

  // ── تفاصيل المحل ──
  static const workingHours = 'assets/Icons/storeWorkingHours.svg';
  static const minOrder = 'assets/Icons/storeMinOrder.svg';
  static const turnaround = 'assets/Icons/storeTurnaround.svg';
  static const offer = 'assets/Icons/storeOffer.svg';
  static const info = 'assets/Icons/storeInfo.svg';

  /// ما يُعرض حين لا شعار للمحل — رمز محايد لا صورة مغسلة عامّة
  static const storeLogoFallback = 'assets/Icons/storeLogoFallback.svg';

  /// كلّها — للاختبار الذي يرسمها ويتحقّق من سلامتها
  static const all = <String>[
    ratingStar,
    ratingStarOutline,
    ratingStarHalf,
    heart,
    heartFilled,
    workingHours,
    minOrder,
    turnaround,
    offer,
    info,
    storeLogoFallback,
  ];
}
