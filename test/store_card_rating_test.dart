// test/store_card_rating_test.dart
//
// ★ ما يحرسه هذا الملف ★
//
// `RatingStars` مُختبَر وحده، وذلك لا يثبت أنه مركَّب في البطاقة. وقد
// وقع هذا فعلاً: بُني المكوّن واختُبر ومرّت اختباراته، وبقيت البطاقة
// على نجمة واحدة ورقم — ولم يظهر إلا حين فتح المستخدم التطبيق.
//
// فالاختبار يرسم البطاقة نفسها ويعدّ ما فيها.
//
// ★ ولماذا الحالات الثلاث في اختبار واحد ★
//
// `AppLocalizations.delegate` يقرأ ملفّ الترجمة من حزمة الأصول، وذلك
// ينجح مرّة واحدة في العملية: أوّل `testWidgets` يرسم البطاقة، وما بعده
// يجد `MaterialApp` فارغاً لأن الترجمة لم تُحلّ — فيُعدّ صفر نجوم ويبدو
// أن المكوّن معطوب وهو سليم.
//
// والحلّ إطار واحد يعيد الرسم ثلاث مرّات. وهو قيد بيئة الاختبار لا عيب
// في الشيفرة — وتوثيقه هنا أنفع من تركه لمن يصطدم به بعدنا.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saleem_dry_clean/components/StoreCard.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/theme/AppIcons.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

Store _store({double rating = 0, int ratingCount = 0}) => Store(
      id: 1,
      name: 'كلين إكسبريس',
      description: 'غسيل وكوي احترافي',
      rating: rating,
      ratingCount: ratingCount,
      productsCount: 12,
      minOrderTotal: 30,
      workingHours: '08:00 - 23:00',
    );

/// التطبيق يحوّل الأرقام إلى عربية-هندية في الواجهة العربية، فالبحث عن
/// «4.3» حرفياً لا يجدها. نطبّع قبل المقارنة بدل أن نكتب «٤٫٣» — فيبقى
/// الاختبار صحيحاً لو بُدّل قرار التحويل يوماً.
String _latin(String? s) {
  if (s == null) return '';
  const ar = '٠١٢٣٤٥٦٧٨٩';
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = ar.indexOf(ch);
    b.write(i >= 0 ? '$i' : ch);
  }
  return b.toString();
}

Finder _number(String expected) =>
    find.byWidgetPredicate((w) => w is Text && _latin(w.data) == expected);

Future<Map<String, int>> _pump(WidgetTester tester, Store store) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: Scaffold(body: StoreCard(store: store)),
    ),
  );
  await tester.pumpAndSettle();

  // البطاقة حاضرة فعلاً — وإلا كان العدّ صفراً لسبب آخر غير الذي نفحصه
  expect(find.byType(StoreCard), findsOneWidget);

  final counts = <String, int>{
    AppIcons.ratingStar: 0,
    AppIcons.ratingStarHalf: 0,
    AppIcons.ratingStarOutline: 0,
  };
  for (final w in tester.widgetList<SvgPicture>(find.byType(SvgPicture))) {
    final name = w.bytesLoader.toString();
    for (final key in counts.keys) {
      if (name.contains(key)) counts[key] = counts[key]! + 1;
    }
  }
  return counts;
}

void main() {
  testWidgets('تقييم بطاقة المحل يُرسم صفّاً', (tester) async {
    // ★ الحالة التي طُلبت لتُرى: ٤٫٣ ★
    var c = await _pump(tester, _store(rating: 4.3, ratingCount: 27));
    expect(c[AppIcons.ratingStar], 4, reason: '٤٫٣ — ممتلئة');
    expect(c[AppIcons.ratingStarHalf], 1, reason: '٤٫٣ — نصف');
    expect(c[AppIcons.ratingStarOutline], 0, reason: '٤٫٣ — فارغة');

    // والرقم وعدد المقيّمين بجانبه: الصفّ يقول «جيّد» ولا يفرّق بين
    // ‎4.3‎ و‎4.5‎، وهما فرقٌ عند من يفاضل
    expect(_number('4.3'), findsOneWidget);
    expect(_number('(27)'), findsOneWidget);

    // ── خمس ممتلئة ──
    c = await _pump(tester, _store(rating: 5, ratingCount: 9));
    expect(c[AppIcons.ratingStar], 5);
    expect(c[AppIcons.ratingStarHalf], 0);

    // ── ٣٫٦ تُقرَّب إلى ثلاث ونصف لا أربع ──
    c = await _pump(tester, _store(rating: 3.6, ratingCount: 4));
    expect(c[AppIcons.ratingStar], 3);
    expect(c[AppIcons.ratingStarHalf], 1);
    expect(c[AppIcons.ratingStarOutline], 1);

    // ★ المحل الجديد ★
    //
    // خمس نجوم فارغة تُقرأ «قُيّم بصفر» لا «لم يُقيَّم بعد» — تهمة على
    // محل لم يبدأ. فنجمة واحدة وكلمة «جديد».
    c = await _pump(tester, _store());
    expect(c[AppIcons.ratingStarOutline], 0);
    expect(c[AppIcons.ratingStar], 1);
    expect(_number('(0)'), findsNothing);
  });
}
