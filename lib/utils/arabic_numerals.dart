import 'package:flutter/widgets.dart';

/// تحويل الأرقام إلى الشكل العربي-الهندي حين تكون الواجهة عربية.
///
/// ★ لماذا لا يوجد مفتاح واحد في فلاتر ★
///
/// فلاتر يرسم النصّ حرفياً كما يصله — لا طبقة بينه وبين الشاشة تعيد
/// كتابته. فالتحويل يقع في مكانين لا ثالث لهما: عند تكوين كل نصّ (٣٩٢
/// موضعاً)، أو في غلاف واحد لـ`Text` تمرّ به كل النصوص.
///
/// اخترنا الغلاف: موضع واحد يُقرأ ويُختبر، وتبديله لاحقاً تعديل ملفّ
/// واحد لا مطاردة أرقام في مئة شاشة.
///
/// ★ ما لا يُحوَّل ★
///
/// الفاصلة العشرية تبقى نقطة لاتينية. العربية تكتبها «٫» (U+066B)،
/// لكنّ خلطها بالأرقام في الأسعار يربك من اعتاد «١٢٦.٥٠» على إيصالات
/// المتاجر. ولو أردتَها لاحقاً فهي سطر واحد أدناه.
class ArabicNumerals {
  ArabicNumerals._();

  static const _arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  /// هل الواجهة عربية الآن؟
  static bool isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  /// يحوّل الأرقام اللاتينية في النصّ إلى عربية-هندية.
  ///
  /// المرور حرفاً حرفاً لا بتعبير نمطي: النصّ قد يكون طويلاً ويُعاد
  /// رسمه عند كل إطار، والتعبير النمطي أبطأ بمراحل في هذا الحجم.
  static String convert(String input) {
    if (input.isEmpty) return input;

    // لا أرقام ⇐ لا عمل ولا تخصيص ذاكرة جديدة
    var hasDigit = false;
    for (var i = 0; i < input.length; i++) {
      final c = input.codeUnitAt(i);
      if (c >= 0x30 && c <= 0x39) {
        hasDigit = true;
        break;
      }
    }
    if (!hasDigit) return input;

    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final c = input.codeUnitAt(i);
      if (c >= 0x30 && c <= 0x39) {
        buffer.write(_arabic[c - 0x30]);
      } else {
        buffer.writeCharCode(c);
      }
    }
    return buffer.toString();
  }

  /// يحوّل حسب لغة الواجهة — الإنجليزية تمرّ كما هي.
  static String forContext(BuildContext context, String input) =>
      isArabic(context) ? convert(input) : input;

  /// يحوّل شجرة `InlineSpan` كاملة — لأجل `Text.rich` و`RichText`.
  ///
  /// الشجرة تُعاد بناؤها لا تُعدَّل: `TextSpan` غير قابل للتغيير.
  static InlineSpan convertSpan(InlineSpan span) {
    if (span is TextSpan) {
      final text = span.text;
      final children = span.children;
      return TextSpan(
        text: text == null ? null : convert(text),
        children: children?.map(convertSpan).toList(),
        style: span.style,
        recognizer: span.recognizer,
        mouseCursor: span.mouseCursor,
        onEnter: span.onEnter,
        onExit: span.onExit,
        semanticsLabel: span.semanticsLabel,
        locale: span.locale,
        spellOut: span.spellOut,
      );
    }
    // WidgetSpan وغيره يمرّ كما هو: محتواه ودجات لا نصّ
    return span;
  }
}

/// راحة عند الاستدعاء لما لا يمرّ بـ`Text` — تلميح حقل أو عنوان تبويب.
extension ArabicNumeralsString on String {
  String ar(BuildContext context) => ArabicNumerals.forContext(context, this);
}
