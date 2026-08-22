import 'package:saleem_dry_clean/services/Models/Service.dart';

class BasketItemData {
  final int productId;
  final String productName;
  final String category;
  final String catalogTypeName;
  final Service serviceType; // Service object instead of a String
  final String imagePath;
  final double price;
  final String unit;
  final int quantity;
  final String subCategory;
  final String area;
  final double? width;
  final double? length;
  final bool measurementPending;
  final double subtotal;

  BasketItemData({
    required this.productId,
    required this.productName,
    required this.category,
    this.catalogTypeName = '',
    required this.serviceType, // Service object
    required this.imagePath,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.subCategory,
    required this.subtotal,
    this.area = "",
    this.width,
    this.length,
    this.measurementPending = false,
  });

  factory BasketItemData.fromJson(Map<String, dynamic> json) {
    return BasketItemData(
      productId: json['productId'],
      productName: json['productName'],
      category: json['category'],
      catalogTypeName: json['catalogTypeName']?.toString() ?? '',
      serviceType:
          Service.fromJson(json['service']), // Deserialize Service object
      imagePath: json['imagePath'],
      price: json['price'],
      unit: json['unit'],
      quantity: json['quantity'],
      subCategory: json['subCategory'],
      area: json['area']?.toString() ?? '',
      width: json['width'] == null ? null : double.tryParse('${json['width']}'),
      length: json['length'] == null ? null : double.tryParse('${json['length']}'),
      measurementPending: json['measurementPending'] == true,
      subtotal: json['subtotal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'category': category,
      'catalogTypeName': catalogTypeName,
      'service': serviceType.toJson(), // Serialize Service object
      'imagePath': imagePath,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'subCategory': subCategory,
      'subtotal': subtotal,
      // ★ المساحة تُكتب كما تُقرأ ★
      //
      // `fromJson` كانت تقرؤها و`toJson` لا تكتبها. فسلّةٌ تُحفظ في
      // الجلسة وتعود تفقد مساحتها: يصير مجموعها صفراً، ويُردّ الطلب.
      //
      // وهي ما يحتاجه الخادم لمن اختار مقاساً جاهزاً بلا بُعدين.
      if (area.isNotEmpty && double.tryParse(area) != null)
        'area': double.parse(area),
      if (width != null) 'width': width,
      if (length != null) 'length': length,
      'measurementPending': measurementPending,
    };
  }

  // Method to calculate subtotal based on the unit type
  static double calculateSubtotal(
      String unit, double price, int quantity, String area) {
    double areaValue = double.tryParse(area) ?? 0.0;
    if (unit == 'Square meter') {
      return areaValue * price * quantity;
    } else {
      return price * quantity;
    }
  }
}
