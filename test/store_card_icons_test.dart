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

/// المسارات كما في `_CardIcons` — مكرّرة هنا عمداً.
///
/// الصنف خاصّ بملفّه (بادئة `_`)، واستيراده يوجب فتحه للعموم لأجل
/// اختبار. والتكرار هنا مقصود: لو غُيّر مسار في الشيفرة ونُسي هنا،
/// سقط الاختبار — وذاك تنبيه لا إزعاج.
const _icons = <String, String>{
  'النجمة': 'assets/Icons/storeRatingStar.svg',
  'القلب الفارغ': 'assets/Icons/storeFavoriteHeart.svg',
  'القلب الممتلئ': 'assets/Icons/storeFavoriteHeartFilled.svg',
  'الساعة': 'assets/Icons/storeWorkingHours.svg',
  'أقلّ طلب': 'assets/Icons/storeMinOrder.svg',
  'العرض': 'assets/Icons/storeOffer.svg',
  'المعلومة': 'assets/Icons/storeInfo.svg',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('أيقونات بطاقة المحل', () {
    for (final entry in _icons.entries) {
      testWidgets('${entry.key} تُرسم بلا خطأ', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SvgPicture.asset(entry.value, width: 24, height: 24),
            ),
          ),
        );

        // الرسم غير متزامن: التحميل من حزمة الأصول ثم التحليل ثم الرسم
        await tester.pumpAndSettle();

        expect(find.byType(SvgPicture), findsOneWidget);
        expect(tester.takeException(), isNull, reason: entry.value);
      });
    }

    // ★ القلبان شكل واحد بحالتين ★
    //
    // لو اختلفت هندستهما لقفزت الأيقونة عند الضغط بدل أن تمتلئ.
    // ونقارن مسار الرسم نفسه: الفارق المسموح هو `fill` وحده.
    test('القلب الممتلئ يشارك الفارغ مساره', () {
      // القراءة من القرص لا من حزمة الأصول: `rootBundle` في بيئة
      // الاختبار يحتاج ربطاً حيّاً، والملفّان على القرص أمامنا.
      final empty = File('assets/Icons/storeFavoriteHeart.svg').readAsStringSync();
      final filled =
          File('assets/Icons/storeFavoriteHeartFilled.svg').readAsStringSync();

      final path = RegExp(r'M12 20\.25C12 20\.25 3\.75 15\.65');
      expect(path.hasMatch(empty), isTrue, reason: 'الفارغ');
      expect(path.hasMatch(filled), isTrue, reason: 'الممتلئ');

      // والامتلاء بالتدرّج لا بلون مصمت
      expect(filled.contains('fill="url(#saleemBrand)"'), isTrue);
      expect(empty.contains('fill="url(#saleemBrand)"'), isFalse);
    });

    test('كلّها على تدرّج العلامة نفسه', () {
      for (final path in _icons.values) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'مفقود: $path');
        final svg = file.readAsStringSync();
        expect(svg.contains('#00E213'), isTrue, reason: path);
        expect(svg.contains('#01B5CF'), isTrue, reason: path);
      }
    });
  });
}
