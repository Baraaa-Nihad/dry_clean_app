import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Cards/ThankYouCard.dart';
import 'package:saleem_dry_clean/components/Cards/payment_method.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDotsPrimary.dart';
import 'package:saleem_dry_clean/screens/Receipt/PaymentDetails.dart';
import 'package:saleem_dry_clean/screens/Receipt/ReceiptDetails.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/services/orderService/OrderService.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

class OrderReceiptPage extends StatefulWidget {
  final OrderData? order;
  final int? orderId;
  final TokenService tokenService; // Pass this from outside

  const OrderReceiptPage({
    Key? key,
    this.order,
    this.orderId,
    required this.tokenService, // Make it a required parameter
  }) : super(key: key);

  @override
  _OrderReceiptPageState createState() => _OrderReceiptPageState();
}

class _OrderReceiptPageState extends State<OrderReceiptPage> {
  bool isLoading = true;
  OrderData? order;
  late OrderService _orderService;

  @override
  void initState() {
    super.initState();

    // Pass the TokenService to OrderService
    _orderService = OrderService(widget.tokenService);

    if (widget.order != null) {
      order = widget.order;
      isLoading = false;
    } else if (widget.orderId != null) {
      _fetchOrderById(widget.orderId!);
    }
  }

  Future<void> _fetchOrderById(int orderId) async {
    try {
      setState(() {
        isLoading = true;
      });
      OrderData fetchedOrder = await _orderService.getOrderById(orderId);
      if (mounted) {
        setState(() {
          order = fetchedOrder;
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching order: $error");
      if (mounted) {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching order: $error')),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppHeader(
        quantityNumber: false,
        prefixIcon: BackButtonWidget(
          onTap: () {
            print('_handleOrdersTap3');
            Future.delayed(Duration(milliseconds: 100), () {
              Provider.of<NavigationProvider>(context, listen: false)
                  .goBack(context); // Adjust based on your navigation logic
            });
          },
        ),
        title: localizations.translate('orderReceipt'),
        fem: 1,
      ),
      backgroundColor: AppColors.white,
      body: isLoading
          ? Center(child: LoadingDotsPrimary(fem: 1))
          : order != null
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.white),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReceiptDetails(
                                order:
                                    order!), // order! ensures it's non-null here
                            PaymentDetails(order: order!),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: PaymentMethod(
                          showLabel: true,
                          paymentMethod: order!.paymentMethod,
                          isPaid: order!.isPaid,
                        ),
                      ),
                      SizedBox(height: 8),
                      ThankYouCard(),
                      SizedBox(height: 60),
                    ],
                  ),
                )
              : Center(child: Text(localizations.translate('orderNotFound'))),
    );
  }
}
