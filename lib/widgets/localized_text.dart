import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart'
    show
        BuildContext,
        InlineSpan,
        Locale,
        StatelessWidget,
        StrutStyle,
        TextAlign,
        TextDirection,
        TextHeightBehavior,
        TextOverflow,
        TextScaler,
        TextStyle,
        TextWidthBasis,
        Widget;
import 'package:saleem_dry_clean/utils/arabic_numerals.dart';

/// `Text` يحوّل أرقامه إلى العربية حين تكون الواجهة عربية.
///
/// ★ لماذا غلاف لا تعديل في كل شاشة ★
///
/// الأرقام في التطبيق تأتي من مصادر لا تُحصى: أسعار محسوبة، وكميات،
/// وتواريخ، وأرقام طلبات، ونصوص تصل من الخادم. وتتبّعها موضعاً موضعاً
/// يعني أن أول سطر جديد يُكتب غداً يعود بالأرقام اللاتينية.
///
/// والغلاف يجعلها قاعدة لا عادة: كل ما يمرّ بـ`Text` يُحوَّل، والجديد
/// يرثه بلا أن ينتبه كاتبه.
///
/// ★ لماذا يبقى الاسم `Text` ★
///
/// كي لا تتغيّر ٣٩٢ سطراً. الشاشة تستورد `ui.dart` بدل `material.dart`
/// فتحصل على هذا الصنف باسمه المعتاد — سطر واحد لكل ملفّ.
class Text extends StatelessWidget {
  const Text(
    String this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null;

  const Text.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = null;

  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final material.Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final arabic = ArabicNumerals.isArabic(context);

    if (textSpan != null) {
      return material.Text.rich(
        arabic ? ArabicNumerals.convertSpan(textSpan!) : textSpan!,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        // التسمية الدلالية تبقى بالأرقام اللاتينية: قارئ الشاشة ينطقها
        // بلغة النظام، والعربية-الهندية تُنطق حرفاً حرفاً عند بعض
        // القارئات
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    return material.Text(
      arabic ? ArabicNumerals.convert(data!) : data!,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

/// `RichText` بالسلوك نفسه — تستعمله ثماني شاشات مباشرة.
class RichText extends StatelessWidget {
  const RichText({
    super.key,
    required this.text,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final InlineSpan text;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final TextScaler textScaler;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final material.Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    return material.RichText(
      text: ArabicNumerals.isArabic(context)
          ? ArabicNumerals.convertSpan(text)
          : text,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
