import 'package:flutter/material.dart' as m;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saleem_dry_clean/ui.dart';
import 'package:saleem_dry_clean/utils/arabic_numerals.dart';

/// يتحقّق أن الغلاف يحوّل عند العربية ولا يمسّ الإنجليزية.
void main() {
  test('التحويل يمسّ الأرقام وحدها', () {
    expect(ArabicNumerals.convert('126.00₪'), '١٢٦.٠٠₪');
    expect(ArabicNumerals.convert('الطلب #431'), 'الطلب #٤٣١');
    expect(ArabicNumerals.convert('بلا أرقام'), 'بلا أرقام');
    expect(ArabicNumerals.convert(''), '');
  });

  Future<void> pump(WidgetTester tester, String locale, String text) {
    return tester.pumpWidget(
      m.MaterialApp(
        locale: m.Locale(locale),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [m.Locale('ar'), m.Locale('en')],
        home: m.Directionality(
          textDirection: m.TextDirection.rtl,
          child: Text(text),
        ),
      ),
    );
  }

  testWidgets('العربية تعرض أرقاماً عربية', (tester) async {
    await pump(tester, 'ar', 'المجموع 146.00');
    expect(find.text('المجموع ١٤٦.٠٠'), findsOneWidget);
  });

  testWidgets('الإنجليزية تبقى كما هي', (tester) async {
    await pump(tester, 'en', 'Total 146.00');
    expect(find.text('Total 146.00'), findsOneWidget);
  });
}
