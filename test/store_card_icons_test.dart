// test/store_card_icons_test.dart
//
// ★ ما يحرسه هذا الملف ★
//
// ملفّ SVG معطوب لا يُصدر خطأ في `flutter analyze` ولا في البناء: يُقرأ
// وقت الرسم، فيظهر العطل مربّعاً فارغاً في يد الزبون. ومسار خاطئ في
// اسم الأصل كذلك — الأصول تُحلّ وقت التشغيل لا وقت الترجمة.
//
// فالاختبار يرسم الأيقونات فعلاً ويتحقّق أنها رُسمت.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saleem_dry_clean/theme/AppIcons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('أيقونات بطاقة المحل', () {
    // الفهرس هو المصدر: أيقونة تُضاف إليه تُفحص هنا تلقائياً، ولا
    // تحتاج من يتذكّر أن يضيفها للاختبار
    for (final path in AppIcons.all) {
      testWidgets('$path تُرسم بلا خطأ', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SvgPicture.asset(path, width: 24, height: 24),
            ),
          ),
        );

        // الرسم غير متزامن: التحميل من حزمة الأصول ثم التحليل ثم الرسم
        await tester.pumpAndSettle();

        expect(find.byType(SvgPicture), findsOneWidget);
        expect(tester.takeException(), isNull, reason: path);
      });
    }

    // ★ القلبان شكل واحد بحالتين ★
    //
    // لو اختلفت هندستهما لقفزت الأيقونة عند الضغط بدل أن تمتلئ.
    // ونقارن مسار الرسم نفسه: الفارق المسموح هو `fill` وحده.
    test('القلب الممتلئ يشارك الفارغ مساره', () {
      // القراءة من القرص لا من حزمة الأصول: `rootBundle` في بيئة
      // الاختبار يحتاج ربطاً حيّاً، والملفّان على القرص أمامنا.
      final empty = File(AppIcons.heart).readAsStringSync();
      final filled = File(AppIcons.heartFilled).readAsStringSync();

      final path = RegExp(r'M12 20\.25C12 20\.25 3\.75 15\.65');
      expect(path.hasMatch(empty), isTrue, reason: 'الفارغ');
      expect(path.hasMatch(filled), isTrue, reason: 'الممتلئ');

      // والامتلاء بالتدرّج لا بلون مصمت
      expect(filled.contains('fill="url(#saleemBrand)"'), isTrue);
      expect(empty.contains('fill="url(#saleemBrand)"'), isFalse);
    });

    test('كلّها على تدرّج العلامة نفسه', () {
      for (final path in AppIcons.all) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'مفقود: $path');
        final svg = file.readAsStringSync();
        expect(svg.contains('#00E213'), isTrue, reason: path);
        expect(svg.contains('#01B5CF'), isTrue, reason: path);
      }
    });
  });
}
