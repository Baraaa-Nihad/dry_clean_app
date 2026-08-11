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
    this.productHasOffer = false,
    this.groupHasOffer = false,
    this.unit = 'item',
    this.sizes = const [],
    this.width,
    this.length,
    this.measurementPending = false,
    this.customSizeTemplate = false,
    this.catalogTypeName,
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
  final bool productHasOffer;
  final bool groupHasOffer;

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
  final double? width;
  final double? length;
  final bool measurementPending;
  final bool customSizeTemplate;
  final String? catalogTypeName;

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
      effectivePrice: j['effectivePrice'] == null
          ? price
          : _d(j['effectivePrice']),
      offerPrice: j['offerPrice'] == null ? null : _d(j['offerPrice']),
      hasOffer: j['hasOffer'] == true,
      // Separate flags keep the Figma hierarchy exact: a category offer is
      // badged on the category header, while a direct offer is badged on the item.
      productHasOffer: j['productHasOffer'] == null
          ? j['hasOffer'] == true
          : j['productHasOffer'] == true,
      groupHasOffer: j['groupHasOffer'] == true,
      unit: (j['unit'] ?? 'item').toString(),
      sizes: ((j['sizes'] as List?) ?? const [])
          .map((e) => ProductSize.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      width: j['width'] == null ? null : _d(j['width']),
      length: j['length'] == null ? null : _d(j['length']),
      measurementPending: j['measurementPending'] == true,
      customSizeTemplate: j['customSizeTemplate'] == true,
      catalogTypeName: j['catalogTypeName'] as String?,
    );
  }
}

/// A customer-facing catalogue item with every service offered by one store.
///
/// The API keeps the natural pricing row (`product + service + store`).  The
/// catalogue, however, is product-first: the customer opens one garment and
/// chooses the required quantities for all available services in one place.
class CatalogProduct {
  CatalogProduct({
    required this.productId,
    required this.name,
    required this.offerings,
    this.groupId,
    this.groupName,
    this.imagePath,
    this.description,
    this.width,
    this.length,
    this.measurementPending = false,
    this.customSizeTemplate = false,
    this.catalogTypeName,
  });

  final int productId;
  final String name;
  final int? groupId;
  final String? groupName;
  final String? imagePath;
  final String? description;
  final double? width;
  final double? length;
  final bool measurementPending;
  final bool customSizeTemplate;
  final String? catalogTypeName;
  final List<StoreProduct> offerings;

  bool get hasOffer => offerings.any((offering) => offering.hasOffer);

  bool get hasProductOffer =>
      offerings.any((offering) => offering.productHasOffer);

  bool get hasGroupOffer => offerings.any((offering) => offering.groupHasOffer);

  int? get bestDiscountPercent {
    int? best;
    for (final offering in offerings) {
      final value = offering.discountPercent;
      if (value != null && (best == null || value > best)) best = value;
    }
    return best;
  }

  /// A stable identity for section keys and cart badges.
  String get key => '$productId';
}

/// قياس سجادة اختاره العميل في طلب سابق.
///
/// القياس ليس كتالوجاً ثابتاً: يعود من سجل الطلبات، ثم تتأكد الشاشة من
/// أن الصنف نفسه ما زال معروضاً من المغسلة قبل السماح باختياره مجدداً.
class PreviousMeasurement {
  const PreviousMeasurement({
    required this.productId,
    required this.serviceId,
    required this.catalogTypeId,
    required this.width,
    required this.length,
    required this.area,
    required this.lastUsedAt,
  });

  final int productId;
  final int serviceId;
  final int catalogTypeId;
  final double width;
  final double length;
  final double area;
  final String? lastUsedAt;

  factory PreviousMeasurement.fromJson(Map<String, dynamic> json) {
    double number(dynamic value) =>
        double.tryParse('${value ?? 0}') ?? 0;

    return PreviousMeasurement(
      productId: int.tryParse('${json['productId'] ?? 0}') ?? 0,
      serviceId: int.tryParse('${json['serviceId'] ?? 0}') ?? 0,
      catalogTypeId: int.tryParse('${json['catalogTypeId'] ?? 0}') ?? 0,
      width: number(json['width']),
      length: number(json['length']),
      area: number(json['area']),
      lastUsedAt: json['lastUsedAt']?.toString(),
    );
  }
}

class CatalogType {
  CatalogType({
    required this.id,
    required this.name,
    required this.groups,
    required this.unit,
    this.imagePath,
    this.allowCustomSize = false,
    this.allowUnknownSize = false,
  });

  final int id;
  final String name;
  final String? imagePath;
  final String unit;
  final bool allowCustomSize;
  final bool allowUnknownSize;
  final List<CatalogGroup> groups;

  bool get isPerSquareMeter => unit == 'Square meter';

  double? get minimumPrice {
    double? value;
    for (final group in groups) {
      for (final product in group.products) {
        for (final offering in product.offerings) {
          if (value == null || offering.effectivePrice < value) {
            value = offering.effectivePrice;
          }
        }
      }
    }
    return value;
  }

  /// A type can include an offer for one size only. In that case its summary
  /// must say "from" rather than implying the discounted price applies to all
  /// carpets in the type.
  bool get hasVariableEffectivePrices {
    double? firstPrice;
    for (final group in groups) {
      for (final product in group.products) {
        for (final offering in product.offerings) {
          if (firstPrice == null) {
            firstPrice = offering.effectivePrice;
          } else if ((offering.effectivePrice - firstPrice).abs() > 0.001) {
            return true;
          }
        }
      }
    }
    return false;
  }

  factory CatalogType.fromJson(Map<String, dynamic> json) {
    final typeId = int.tryParse('${json['id']}') ?? 0;
    final typeName = (json['name'] ?? '').toString();
    final unit = (json['unit'] ?? 'item').toString();
    final groups = ((json['groups'] as List?) ?? const [])
        .map((entry) => CatalogGroup.fromJson(
              Map<String, dynamic>.from(entry as Map),
              typeId: typeId,
              typeName: typeName,
              unit: unit,
            ))
        .toList();
    return CatalogType(
      id: typeId,
      name: typeName,
      imagePath: json['imagePath'] as String?,
      unit: unit,
      allowCustomSize: json['allowCustomSize'] == true,
      allowUnknownSize: json['allowUnknownSize'] == true,
      groups: groups,
    );
  }
}

class CatalogGroup {
  CatalogGroup({required this.id, required this.name, required this.products});

  final int id;
  final String name;
  final List<CatalogProduct> products;

  factory CatalogGroup.fromJson(
    Map<String, dynamic> json, {
    required int typeId,
    required String typeName,
    required String unit,
  }) {
    final groupId = int.tryParse('${json['id']}') ?? 0;
    final groupName = (json['name'] ?? '').toString();
    final products = <CatalogProduct>[];
    for (final raw in (json['items'] as List?) ?? const []) {
      final item = Map<String, dynamic>.from(raw as Map);
      final offerings = <StoreProduct>[];
      for (final rawOffering in (item['offerings'] as List?) ?? const []) {
        final merged = <String, dynamic>{
          ...item,
          ...Map<String, dynamic>.from(rawOffering as Map),
          'groupId': groupId,
          'groupName': groupName,
          'unit': unit,
          'catalogTypeName': typeName,
        };
        offerings.add(StoreProduct.fromJson(merged));
      }
      if (offerings.isEmpty) continue;
      products.add(CatalogProduct(
        productId: int.tryParse('${item['productId']}') ?? 0,
        name: (item['name'] ?? '').toString(),
        description: item['description'] as String?,
        groupId: groupId,
        groupName: groupName,
        imagePath: (item['thumbnailPath'] ?? item['imagePath']) as String?,
        width: item['width'] == null ? null : StoreProduct._d(item['width']),
        length: item['length'] == null ? null : StoreProduct._d(item['length']),
        measurementPending: item['measurementPending'] == true,
        customSizeTemplate: item['customSizeTemplate'] == true,
        catalogTypeName: typeName,
        offerings: offerings,
      ));
    }
    return CatalogGroup(id: groupId, name: groupName, products: products);
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
  Map<String, List<StoreProduct>> byGroup({required String fallbackGroup}) {
    final map = <String, List<StoreProduct>>{};
    for (final p in products) {
      final k = (p.groupName ?? '').isEmpty ? fallbackGroup : p.groupName!;
      map.putIfAbsent(k, () => []).add(p);
    }
    return map;
  }
}
