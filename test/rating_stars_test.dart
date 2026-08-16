// test/rating_stars_test.dart
//
// ★ ما يحرسه هذا الملف ★
//
// صفّ النجوم يترجم رقماً إلى صورة، والصورة تُقرأ أسرع من الرقم. فخطأ
// نصف نجمة يكذب على الزبون في اتّجاه: ‎4.9‎ بأربع نجوم يبخس محلاً جيّداً،
// و‎4.1‎ بأربع ونصف يمدح محلاً أقلّ.
//
// وهذا لا يظهر في `analyze` ولا في مراجعة بالعين — الفرق نصف شكل.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saleem_dry_clean/components/Rating/RatingStars.dart';
import 'package:saleem_dry_clean/theme/AppIcons.dart';

/// يعدّ الأيقونات المرسومة بحسب نوعها.
Future<Map<String, int>> _render(
  WidgetTester tester,
  double score, {
  ValueChanged<int>? onRate,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(child: RatingStars(score: score, onRate: onRate)),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final counts = <String, int>{
    AppIcons.ratingStar: 0,
    AppIcons.ratingStarHalf: 0,
    AppIcons.ratingStarOutline: 0,
  };

  for (final w in tester.widgetList<SvgPicture>(find.byType(SvgPicture))) {
    final loader = w.bytesLoader;
    final name = loader.toString();
    for (final key in counts.keys) {
      if (name.contains(key)) counts[key] = counts[key]! + 1;
    }
  }
  return counts;
}

void main() {
  group('صفّ نجوم التقييم', () {
    testWidgets('خمس نجوم دائماً', (tester) async {
      for (final score in [0.0, 2.5, 4.3, 5.0]) {
        await _render(tester, score);
        expect(find.byType(SvgPicture), findsNWidgets(5), reason: '$score');
      }
    });

    testWidgets('الصحيح يملأ بلا نصف', (tester) async {
      final c = await _render(tester, 4.0);
      expect(c[AppIcons.ratingStar], 4);
      expect(c[AppIcons.ratingStarHalf], 0);
      expect(c[AppIcons.ratingStarOutline], 1);
    });

    // ★ الحالة التي طُلبت لتُرى ★
    testWidgets('٤٫٣ تُرسم أربعاً ونصفاً', (tester) async {
      final c = await _render(tester, 4.3);
      expect(c[AppIcons.ratingStar], 4);
      expect(c[AppIcons.ratingStarHalf], 1);
      expect(c[AppIcons.ratingStarOutline], 0);
    });

    // ★ ولا تُجمَّل ولا تُبخَس ★
    testWidgets('٤٫١ لا تصير أربعاً ونصفاً', (tester) async {
      final c = await _render(tester, 4.1);
      expect(c[AppIcons.ratingStarHalf], 0);
      expect(c[AppIcons.ratingStar], 4);
      expect(c[AppIcons.ratingStarOutline], 1);
    });

    testWidgets('٤٫٩ تصير خمساً لا أربعاً ونصفاً', (tester) async {
      final c = await _render(tester, 4.9);
      expect(c[AppIcons.ratingStar], 5);
      expect(c[AppIcons.ratingStarHalf], 0);
    });

    testWidgets('الصفر كلّه فارغ', (tester) async {
      final c = await _render(tester, 0);
      expect(c[AppIcons.ratingStarOutline], 5);
      expect(c[AppIcons.ratingStar], 0);
    });

    // رقم شاذّ من الخادم لا يكسر الصفّ
    testWidgets('ما فوق الخمسة يُحَدّ', (tester) async {
      final c = await _render(tester, 9.7);
      expect(c[AppIcons.ratingStar], 5);
    });

    testWidgets('والسالب يُحَدّ', (tester) async {
      final c = await _render(tester, -3);
      expect(c[AppIcons.ratingStarOutline], 5);
    });

    // ★ الإدخال لا نصف فيه ★
    //
    // الزبون يختار عدداً صحيحاً. ونصف نجمة في أداة اختيار يوحي أنه
    // يستطيع اختياره — ولا يستطيع.
    testWidgets('الإدخال بلا أنصاف', (tester) async {
      final c = await _render(tester, 3.5, onRate: (_) {});
      expect(c[AppIcons.ratingStarHalf], 0);
      expect(c[AppIcons.ratingStar], 4); // 3.5 تُقرَّب إلى 4
    });

    testWidgets('الضغط يُبلّغ الرقم المختار', (tester) async {
      int? picked;
      await _render(tester, 0, onRate: (v) => picked = v);

      await tester.tap(find.byType(SvgPicture).at(2));
      await tester.pumpAndSettle();

      expect(picked, 3);
    });

    testWidgets('والعرض لا يستجيب للضغط', (tester) async {
      await _render(tester, 3);
      expect(find.byType(InkResponse), findsNothing);
    });
  });
}
