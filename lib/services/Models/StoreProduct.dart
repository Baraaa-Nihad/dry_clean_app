/// منتج بسعر محل بعينه.
///
/// ★ لماذا نموذج منفصل عن Product ★
///
/// Product القائم يصف الصنف في كتالوج المنصّة: اسم وصورة ومجموعة، ثم
/// قائمة خدمات لكل منها سعر عام. وهذا كان صحيحاً حين كان السعر واحداً.
///
/// أمّا الآن فالسعر خاصية العلاقة بين المنتج والمحل لا خاصية المنتج:
/// نفس القميص بشيكلين هنا وبثلاثة هناك. فالوحدة الطبيعية صارت
/// «منتج + خدمة + محل» — وهي ما يمثّله هذا النموذج، وما يحمله سطر
/// السلّة، وما يُسعّره الخادم عند الطلب.
class StoreProduct {
  StoreProduct({
    required this.productId,
    required this.name,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.effectivePrice,
    this.groupId,
    this.groupName,
    this.imagePath,
    this.offerPrice,
    this.hasOffer = false,
    this.unit = 'item',
    this.sizes = const [],
  });

  final int productId;
  final String name;
  final int? groupId;
  final String? groupName;
  final String? imagePath;

  final int serviceId;
  final String serviceName;

  /// السعر المعلن قبل الخصم
  final double price;

  /// ما يُحتسب فعلاً — يحسبه الخادم لا التطبيق كي لا يختلف حسابان
  /// لنفس القيمة، فيرى الزبون سعراً ويُحاسَب بآخر
  final double effectivePrice;

  final double? offerPrice;
  final bool hasOffer;

  /// وحدة التسعير: `item` للقطعة أو `Square meter` للمتر المربّع.
  ///
  /// ★ لماذا تهمّ ★
  ///
  /// سجادة ٤×٦ بسعر ١٠ للمتر ثمنها ٢٤٠ لا ١٠. وبلا هذا الحقل يضيفها
  /// التطبيق بسعر متر واحد — الزبون يدفع أقلّ بستّة وتسعين بالمئة،
  /// والمحل يغسل سجادة بثمن منديل.
  final String unit;

  /// المقاسات الجاهزة — الزبون يختار منها بدل قياس سجادته بنفسه
  final List<ProductSize> sizes;

  bool get isPerSquareMeter => unit == 'Square meter';

  /// مفتاح السطر في السلّة: الصنف نفسه بخدمتين سطران لا سطر واحد
  String get key => '$productId-$serviceId';

  /// نسبة التوفير للشارة الحمراء — تُعرض فقط حين تساوي 1% فأكثر
  int? get discountPercent {
    if (!hasOffer || price <= 0 || effectivePrice >= price) return null;
    final pct = ((price - effectivePrice) / price * 100).round();
    return pct > 0 ? pct : null;
  }

  static double _d(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

  factory StoreProduct.fromJson(Map<String, dynamic> j) {
    final price = _d(j['price']);
    return StoreProduct(
      productId: int.tryParse('${j['productId']}') ?? 0,
      name: (j['name'] ?? '').toString(),
      groupId: j['groupId'] == null ? null : int.tryParse('${j['groupId']}'),
      groupName: j['groupName'] as String?,
      // المصغّرة أولاً — قائمة من ثلاثين صنفاً تحمّل ثلاثين صورة كاملة
      imagePath: (j['thumbnailPath'] ?? j['imagePath']) as String?,
      serviceId: int.tryParse('${j['serviceId']}') ?? 0,
      serviceName: (j['serviceName'] ?? '').toString(),
      price: price,
      // الاحتياط للسعر المعلن لا للصفر: صفر يعني «مجاني» وهو أسوأ خطأ
      // يمكن عرضه على الزبون
      effectivePrice:
          j['effectivePrice'] == null ? price : _d(j['effectivePrice']),
      offerPrice: j['offerPrice'] == null ? null : _d(j['offerPrice']),
      hasOffer: j['hasOffer'] == true,
      unit: (j['unit'] ?? 'item').toString(),
      sizes: ((j['sizes'] as List?) ?? const [])
          .map((e) => ProductSize.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

/// مقاس جاهز لصنف يُسعَّر بالمتر المربّع.
class ProductSize {
  const ProductSize({
    required this.height,
    required this.width,
    required this.area,
  });

  final double height;
  final double width;
  final double area;

  /// «٤ × ٦ م» — أوضح للزبون من «٢٤ م²» وحدها
  String get label =>
      '${_n(width)} × ${_n(height)} م  ·  ${_n(area)} م²';

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  factory ProductSize.fromJson(Map<String, dynamic> j) => ProductSize(
        height: double.tryParse('${j['height'] ?? 0}') ?? 0,
        width: double.tryParse('${j['width'] ?? 0}') ?? 0,
        area: double.tryParse('${j['area'] ?? 0}') ?? 0,
      );
}

/// خدمة المحل وما تحتها من أصناف — بنية تبويب الشاشة.
class StoreService {
  StoreService({
    required this.serviceId,
    required this.serviceName,
    required this.products,
  });

  final int serviceId;
  final String serviceName;
  final List<StoreProduct> products;

  factory StoreService.fromJson(Map<String, dynamic> j) => StoreService(
        serviceId: int.tryParse('${j['serviceId']}') ?? 0,
        serviceName: (j['serviceName'] ?? '').toString(),
        products: ((j['products'] as List?) ?? const [])
            .map((e) => StoreProduct.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  /// الأصناف مجمّعة بالمجموعة، مرتّبة كما وردت من الخادم.
  ///
  /// LinkedHashMap ضمناً: ترتيب الإدخال محفوظ في Dart، والخادم يرتّب
  /// حسب sort_id — فالمجموعات تظهر بالترتيب الذي ضبطه المحل.
  Map<String, List<StoreProduct>> get byGroup {
    final map = <String, List<StoreProduct>>{};
    for (final p in products) {
      final k = (p.groupName ?? '').isEmpty ? 'أخرى' : p.groupName!;
      map.putIfAbsent(k, () => []).add(p);
    }
    return map;
  }
}
