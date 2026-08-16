// test/store_card_rating_test.dart
//
// ★ ما يحرسه هذا الملف ★
//
// `RatingStars` مُختبَر وحده، وذلك لا يثبت أنه مركَّب في البطاقة. وقد
// وقع هذا فعلاً: بُني المكوّن واختُبر، وبقيت البطاقة على نجمة واحدة
// ورقم — ولم يظهر ذلك إلا حين فتح المستخدم التطبيق.
//
// فالاختبار يرسم البطاقة نفسها ويعدّ ما فيها.

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
  group('تقييم بطاقة المحل', () {
    // ★ الحالة التي طُلبت لتُرى ★
    testWidgets('٤٫٣ تُرسم صفّاً: أربع ونصف', (tester) async {
      final c = await _pump(tester, _store(rating: 4.3, ratingCount: 27));

      expect(c[AppIcons.ratingStar], 4);
      expect(c[AppIcons.ratingStarHalf], 1);
      expect(c[AppIcons.ratingStarOutline], 0);

      // والرقم وعدد المقيّمين بجانبه: الصفّ يقول «جيّد» ولا يفرّق بين
      // ‎4.3‎ و‎4.5‎
      expect(find.text('4.3'), findsOneWidget);
      expect(find.text('(27)'), findsOneWidget);
    });

    testWidgets('٥٫٠ خمس ممتلئة', (tester) async {
      final c = await _pump(tester, _store(rating: 5, ratingCount: 9));
      expect(c[AppIcons.ratingStar], 5);
      expect(c[AppIcons.ratingStarHalf], 0);
    });

    // ★ المحل الجديد ★
    //
    // خمس نجوم فارغة تُقرأ «قُيّم بصفر» لا «لم يُقيَّم بعد» — تهمة على
    // محل لم يبدأ.
    testWidgets('بلا تقييم: نجمة واحدة وكلمة جديد لا صفّ فارغ', (tester) async {
      final c = await _pump(tester, _store());

      expect(c[AppIcons.ratingStarOutline], 0);
      expect(c[AppIcons.ratingStar], 1);
      expect(find.text('(0)'), findsNothing);
    });
  });
}
