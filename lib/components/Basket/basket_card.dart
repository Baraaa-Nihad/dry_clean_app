import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/Basket/basket_item.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';

class BasketCard extends StatelessWidget {
  final List<BasketItem> items;
  final double fem;

  const BasketCard({
    Key? key,
    required this.items,
    required this.fem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
// Added padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map((item) => Container(
                child: item,
              )),
          SizedBox(height: 20 * fem),
        ],
      ),
    );
  }
}
