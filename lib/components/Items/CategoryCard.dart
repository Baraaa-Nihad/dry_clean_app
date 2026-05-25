import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Items/ShimmerImage.dart';
import 'package:saleem_dry_clean/components/Modals/BlankCategoryModal.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/services/Providers/ServiceTypeProvider.dart';
import 'package:shimmer/shimmer.dart';

class MainCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final double fem;
  final String pricePerUnit;
  final Function(int) fetchProductServices;

  const MainCard({
    Key? key,
    required this.title,
    required this.items,
    required this.fem,
    required this.pricePerUnit,
    required this.fetchProductServices,
  }) : super(key: key);

  void _showProductDetails(BuildContext context, int? productId, double fem,
      String? imagePath, String? productName, String area) {
    if (productId == null || productName == null || imagePath == null) {
      print('Error: productId, productName, or imagePath is null');
      return;
    }

    final serviceTypeProvider =
        Provider.of<ServiceTypeProvider>(context, listen: false);
    final productServices = serviceTypeProvider.getProductServices(productId);

    if (productServices != null) {
      Map<String, Map<String, dynamic>> services = {
        for (var service in productServices)
          service.serviceName: {
            'productId': productId,
            'productName': productName,
            'price': double.tryParse(service.price) ?? 0.0,
            'unit': pricePerUnit,
            'serviceTypeId': service.id, // Include the ID here
          },
      };
      showItemDetailsModal(context, fem, title, productName, imagePath,
          services, pricePerUnit, area);
    } else {
      print('No services found for productId: $productId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * fem),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12 * fem),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsetsDirectional.only(
                start: 20 * fem,
                end: 20 * fem,
                top: 8 * fem,
              ),
              height: 56,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                title,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.bold16Gray80(context).copyWith(
                    fontSize: 18.0 * fem,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Divider(
              color: AppColors.gray20,
              thickness: 0.5,
              height: 0.5,
            ),
            Padding(
              padding: EdgeInsets.all(16 * fem),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> item = entry.value;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => _showProductDetails(
                          context,
                          item['productId'],
                          fem,
                          item['imagePath'],
                          item['label'],
                          item['area'],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8 * fem),
                          child: Row(
                            children: [
                              SizedBox(width: 16 * fem),
                              // Image with shimmer effect until fully loaded
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: ShimmerImage(
                                  imageUrl: item['imagePathThum'],
                                  width: 48,
                                  height: 48,
                                  borderRadius: BorderRadius.circular(12 * fem),
                                ),
                              ),
                              SizedBox(width: 16 * fem),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    item['label'],
                                    style: AppTextStyles.getFontFamily(
                                      context,
                                      AppTextStyles.regular16Gray70(context)
                                          .copyWith(
                                              fontSize: 16.0 * fem,
                                              fontWeight: FontWeight.w500,
                                              height: 2.4),
                                    ),
                                  ),
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/vectors/plus_icon.svg',
                                width: 48 * fem,
                                height: 48 * fem,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (index != items.length - 1)
                        Divider(
                          color: AppColors.gray20,
                          thickness: 0.5,
                          indent:
                              32 * fem + 48, // Ensure padding after the image
                          endIndent: 16 *
                              fem, // Ensure equal padding before the plus icon
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showItemDetailsModal(
    BuildContext context,
    double fem,
    String title,
    String productName,
    String imagePath,
    Map<String, Map<String, dynamic>> services,
    String pricePerUnit,
    String area) {
  print("showItemDetailsModal");
  print(area);
  // Pass pricePerUnit here
  BlankCategoryModal.show(
    context,
    area: area,
    pricePerUnit: pricePerUnit, // Use pricePerUnit
    mainTitle: title,
    subTitle: productName,
    imagePath: imagePath,
    prefixIconPath: 'assets/vectors/close_icon.svg',
    onPrefixIconTap: () {
      Navigator.pop(context);
    },
    fem: fem,
    isDisabledButton: true,
    services: services,
  );
}
