// test/product_size_sheet_layout_test.dart
//
// ★ ما يحرسه هذا الملف ★
//
// زرّ «إضافة للسلّة» في ورقة المقاس كان في آخر ممرٍّ يمرّ. فمن فتحها
// على هاتفٍ قصير وسجادةٍ بمقاسات كثيرة رأى نصف الزرّ تحت حافّة الشاشة،
// ولا شيء يقول إن تحتها شيئاً.
//
// وهذا عطلٌ لا يظهر في flutter analyze ولا في البناء: التخطيط يُحسب
// وقت الرسم وبمقاس الجهاز. فالمقاس هو ما يُختبَر هنا.
//
// ★ ولماذا ثلاث شاشات وشريط إيماءات ★
//
// لأن العطل في التقائهما: شاشةٌ قصيرة تجعل المحتوى يفيض، وشريط
// إيماءاتٍ يقتطع من الأسفل ما ظُنّ فارغاً. وأيّهما وحده لا يكشفه.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saleem_dry_clean/screens/Stores/product_size_sheet.dart';
import 'package:saleem_dry_clean/services/Models/StoreProduct.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

/// ★ مندوب ترجمة متزامن ★
///
/// مندوب التطبيق يقرأ ملفّ JSON من الأصول، وهو غير متزامن. وداخل
/// testWidgets يُزيَّف الزمن، فلا يكتمل ذلك العمل الحقيقي إلّا في أوّل
/// اختبار من كل ملفّ — وما بعده يُبنى على شجرةٍ فارغة بلا خطأ يُقال.
///
/// فيُقرأ الملفّ مرّةً في setUpAll — وهي خارج الزمن المزيَّف — ويُسلَّم
/// جاهزاً. والترجمات ترجماتُ التطبيق نفسها لا بدائل: اختبارٌ على نصوصٍ
/// مخترعة لا يكشف مفتاحاً ناقصاً.
class _ReadyLocalizations extends LocalizationsDelegate<AppLocalizations> {
  const _ReadyLocalizations(this.value);
  final AppLocalizations value;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(value);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

late AppLocalizations _ar;

StoreProduct _carpet({required int sizeCount}) => StoreProduct(
      productId: 1,
      name: 'سجاد صوف',
      serviceId: 6,
      serviceName: 'غسيل',
      price: 12,
      effectivePrice: 12,
      unit: 'Square meter',
      sizes: List.generate(
        sizeCount,
        (i) => ProductSize(
          height: 2 + i.toDouble(),
          width: 3,
          area: (2 + i) * 3,
        ),
      ),
    );

/// يضبط الجهاز، ويفتح الورقة، ويترك المؤشّر عندها.
Future<void> _openSheet(
  WidgetTester tester, {
  required StoreProduct product,
  required Size screen,
  required double gestureInset,
}) async {
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 1.0;

  // ★ viewPadding لا padding ★
  //
  // ضبط padding مباشرةً في TestFlutterView يُخرج الشجرة فارغة.
  // وviewPadding هي التي تقرؤها الورقة أصلاً: حدُّ الجهاز بصرف النظر
  // عن لوحة المفاتيح.
  tester.view.viewPadding = FakeViewPadding(bottom: gestureInset);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar', ''),
      localizationsDelegates: [
        _ReadyLocalizations(_ar),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('ar', '')],
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showProductSizeSheet(context, product: product),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _ar = AppLocalizations(const Locale('ar', ''));
    await _ar.load();
  });

  group('ورقة المقاس تُقاس بالشاشة', () {
    // شاشاتٌ حقيقية: قصيرة، ومتوسّطة، وطويلة
    const screens = <String, Size>{
      'قصيرة 360×640': Size(360, 640),
      'متوسّطة 393×786': Size(393, 786),
      'طويلة 412×915': Size(412, 915),
    };

    const gesture = 48.0; // شريط إيماءات نموذجي

    for (final entry in screens.entries) {
      for (final sizeCount in [2, 6, 14]) {
        testWidgets(
          '${entry.key} · $sizeCount مقاسات — الزرّ كاملٌ فوق شريط الإيماءات',
          (tester) async {
            await _openSheet(
              tester,
              product: _carpet(sizeCount: sizeCount),
              screen: entry.value,
              gestureInset: gesture,
            );

            final button = find.widgetWithText(ElevatedButton, 'إضافة للسلّة');
            expect(button, findsOneWidget,
                reason: 'الزرّ يجب أن يُبنى ويُرى بلا تمرير');

            final box = tester.getRect(button);
            final touchLimit = entry.value.height - gesture;

            // ★ الحدّ ليس حافّة الشاشة بل حافّة ما يُلمَس ★
            expect(
              box.bottom,
              lessThanOrEqualTo(touchLimit),
              reason: 'أسفل الزرّ ${box.bottom} تجاوز حدّ اللمس '
                  '$touchLimit — يُرى ولا يُضغط',
            );
            expect(box.top, greaterThanOrEqualTo(0.0),
                reason: 'أعلى الزرّ خرج من الشاشة');
            expect(box.height, greaterThan(40.0),
                reason: 'الزرّ انضغط إلى ارتفاعٍ لا يُلمَس');
          },
        );
      }
    }

    testWidgets('والورقة لا تبتلع الشاشة كلّها', (tester) async {
      const screen = Size(360, 640);
      await _openSheet(
        tester,
        product: _carpet(sizeCount: 14),
        screen: screen,
        gestureInset: gesture,
      );

      // فجوةٌ فوقها تقول إنها ورقةٌ تزول، لا صفحةٌ يُبحث فيها عن رجوع
      final sheet = tester.getRect(
        find
            .ancestor(
              of: find.text('إضافة للسلّة'),
              matching: find.byType(ConstrainedBox),
            )
            .last,
      );
      expect(sheet.height, lessThan(screen.height),
          reason: 'الورقة ملأت الشاشة فصارت صفحة');
    });

    testWidgets('والزرّ يبقى في موضعه بعد التمرير إلى آخر المقاسات',
        (tester) async {
      await _openSheet(
        tester,
        product: _carpet(sizeCount: 14),
        screen: const Size(360, 640),
        gestureInset: gesture,
      );

      final button = find.widgetWithText(ElevatedButton, 'إضافة للسلّة');
      final before = tester.getRect(button);

      // نزولٌ إلى قاع الممرّ — وهو ما كان يُخفي الزرّ
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -600));
      await tester.pumpAndSettle();

      final after = tester.getRect(button);
      expect(after, equals(before),
          reason: 'الزرّ خارج الممرّ، فلا يتحرّك بتمريره');
      expect(after.bottom, lessThanOrEqualTo(640.0 - gesture));
    });
  });
}
