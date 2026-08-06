/// مرحلة واحدة في مسار الطلب.
///
/// ★ الاسم واللون من الخادم لا من التطبيق ★
///
/// الحالة الواحدة لها ثلاث تسميات: ما يراه الزبون، وما يراه المحل، وما
/// يراه السائق. «استُلم من الزبون» عند الزبون هي «وصل الغسيل» عند المحل.
/// والخادم يعرف من يسأل فيردّ تسميته هو — فلو ترجم التطبيق `code` بنفسه
/// لاحتاج نسخة من الجدول الثلاثي، وتنفرد نسخته عن الخادم عند أول تعديل.
class TrackingStep {
  TrackingStep({
    required this.code,
    required this.name,
    this.color,
    this.at,
    this.by,
  });

  final String code;
  final String name;

  /// لون الحالة كما ضبطته الإدارة — سداسي مثل `#22C55E`
  final String? color;
  final DateTime? at;

  /// من نفّذ الانتقال — يظهر للزبون كـ«بواسطة أحمد» عند وجوده
  final String? by;

  factory TrackingStep.fromJson(Map<String, dynamic> j) => TrackingStep(
        code: (j['code'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        color: j['color'] as String?,
        at: j['at'] == null ? null : DateTime.tryParse(j['at'].toString()),
        by: j['by'] as String?,
      );
}

class OrderTracking {
  OrderTracking({
    required this.current,
    required this.history,
    this.view = 'customer',
  });

  final TrackingStep current;
  final List<TrackingStep> history;
  final String view;

  /// الطلب المنتهي — لا خطوة قادمة بعده.
  ///
  /// يُقرأ من `code` لا من الاسم: الأسماء تُعدَّل من لوحة التحكم
  /// والرموز ثابتة.
  bool get isFinished =>
      current.code == 'delivered' ||
      current.code == 'cancelled' ||
      current.code == 'undelivered';

  bool get isCancelled =>
      current.code == 'cancelled' || current.code == 'undelivered';

  factory OrderTracking.fromJson(Map<String, dynamic> j) {
    final cur = j['current'];
    return OrderTracking(
      view: (j['view'] ?? 'customer').toString(),
      current: TrackingStep.fromJson(
          Map<String, dynamic>.from((cur ?? const {}) as Map)),
      history: ((j['history'] as List?) ?? const [])
          .map((e) => TrackingStep.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

/// جهة قابلة للتقييم بعد إتمام الطلب: المحل، سائق الاستلام، سائق التوصيل.
class RatableTarget {
  RatableTarget({
    required this.type,
    required this.id,
    required this.label,
    required this.question,
    required this.rated,
  });

  final String type;
  final int id;
  final String label;

  /// سؤال مخصّص لكل جهة — «كيف كانت جودة الخدمة؟» للمحل، وسؤال آخر
  /// للسائق. يأتي من الخادم كي لا يفترق نصّان
  final String question;
  final bool rated;

  factory RatableTarget.fromJson(Map<String, dynamic> j) => RatableTarget(
        type: (j['type'] ?? '').toString(),
        id: int.tryParse('${j['id']}') ?? 0,
        label: (j['label'] ?? '').toString(),
        question: (j['question'] ?? '').toString(),
        rated: j['rated'] == true,
      );
}

class RatableOrder {
  RatableOrder({
    required this.ratable,
    required this.targets,
    this.reason,
  });

  final bool ratable;
  final List<RatableTarget> targets;

  /// سبب تعذّر التقييم — «الطلب لم يكتمل بعد» مثلاً
  final String? reason;

  factory RatableOrder.fromJson(Map<String, dynamic> j) => RatableOrder(
        ratable: j['ratable'] == true,
        reason: j['reason'] as String?,
        targets: ((j['targets'] as List?) ?? const [])
            .map((e) =>
                RatableTarget.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
