/// المحل كما يراه الزبون في قائمة الاختيار.
///
/// ★ لماذا نموذج جديد بجانب DryClean ★
///
/// DryClean القائم يخدم التدفّق القديم: يُختار المحل عند الدفع فيكفيه
/// الاسم والهاتف ورسوم التوصيل. أمّا الاختيار المسبق فيحتاج ما يُفاضل
/// به: تقييم وعدد طلبات وحدّ أدنى ومدّة تجهيز وعدد أصناف ومتوسّط سعر.
///
/// وتعديل DryClean نفسه يكسر شاشات الدفع القائمة، فالنموذجان يتعايشان
/// حتى ينتهي الانتقال.
class Store {
  Store({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.rating = 0,
    this.ratingCount = 0,
    this.ordersCount = 0,
    this.productsCount = 0,
    this.averagePrice,
    this.minOrderTotal = 0,
    this.turnaroundHours,
    this.hasActiveOffer = false,
    this.isPromoted = false,
    this.isFavorite = false,
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.workingHours,
  });

  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;

  final double rating;
  final int ratingCount;
  final int ordersCount;

  /// عدد الأصناف المسعَّرة — محل بلا أصناف لا يُطلب منه
  final int productsCount;
  final double? averagePrice;

  final double minOrderTotal;

  /// مدّة التجهيز المتوقّعة بالساعات
  final int? turnaroundHours;

  final bool hasActiveOffer;
  final bool isPromoted;
  final bool isFavorite;

  final String? address;
  final String? phone;
  final double? latitude;
  final double? longitude;

  /// ساعات العمل كما يكتبها المحل — نصّ حرّ لا بنية.
  ///
  /// الوثيقة (٢.١.٢) تطلب عرضها على الكرت. والحقل في القاعدة
  /// `operation_time` نصّ يكتبه المحل بنفسه، فلا يُحلَّل هنا: تحليل نصّ
  /// حرّ يفشل عند أول محل يكتب «من ٨ للـ٨ ما عدا الجمعة».
  final String? workingHours;

  /// محل بلا أصناف مسعَّرة لا يستطيع تنفيذ طلب، فيُعرض معطَّلاً لا مخفياً:
  /// إخفاؤه يجعل الزبون يسأل «أين المحل الذي رأيته أمس».
  bool get canOrder => productsCount > 0;

  bool get hasRating => ratingCount > 0;

  static double? _d(dynamic v) =>
      v == null ? null : double.tryParse(v.toString());
  static int _i(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

  factory Store.fromJson(Map<String, dynamic> j) => Store(
        id: _i(j['id']),
        name: (j['name'] ?? '').toString(),
        description: j['description'] as String?,
        logoUrl: j['logoUrl'] as String?,
        coverUrl: j['coverUrl'] as String?,
        rating: _d(j['rating']) ?? 0,
        ratingCount: _i(j['ratingCount']),
        ordersCount: _i(j['ordersCount']),
        productsCount: _i(j['productsCount']),
        averagePrice: _d(j['averagePrice']),
        minOrderTotal: _d(j['minOrderTotal']) ?? 0,
        turnaroundHours:
            j['turnaroundHours'] == null ? null : _i(j['turnaroundHours']),
        hasActiveOffer: j['hasActiveOffer'] == true,
        isPromoted: j['isPromoted'] == true,
        isFavorite: j['isFavorite'] == true,
        address: j['address'] as String?,
        phone: j['phone'] as String?,
        latitude: _d(j['latitude']),
        longitude: _d(j['longitude']),
        // Production currently sends `processingHours` as a number, while
        // older responses used text. Accept both so a valid catalogue response
        // is not misreported as a connection failure.
        workingHours: j['processingHours'] == null
            ? null
            : j['processingHours'].toString(),
      );
}
