import 'package:saleem_dry_clean/ui.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Cards/ThankYouCard.dart';
import 'package:saleem_dry_clean/components/Cards/payment_method.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDotsPrimary.dart';
import 'package:saleem_dry_clean/screens/Receipt/PaymentDetails.dart';
import 'package:saleem_dry_clean/screens/Receipt/ReceiptDetails.dart';
import 'package:saleem_dry_clean/screens/main_navigation.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/services/orderService/OrderService.dart';

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

  void _goToMainNavigation() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainNavigation(initialIndex: 0),
      ),
      (_) => false,
    );
  }

  @override
  void initState() {
    super.initState();

    // Pass the TokenService to OrderService
    _orderService = OrderService(widget.tokenService);

    final orderId = widget.orderId ?? widget.order?.orderId;
    if (orderId != null) {
      // The active locale is inherited from the app, so wait until the first
      // frame before reading it and requesting the localized receipt.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchOrderById(orderId);
      });
    } else if (widget.order != null) {
      order = widget.order;
      isLoading = false;
    }
  }

  Future<void> _fetchOrderById(int orderId) async {
    try {
      setState(() {
        isLoading = true;
      });
      OrderData fetchedOrder = await _orderService.getOrderById(
        orderId,
        language: Localizations.localeOf(context).languageCode,
      );
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
    final localizations = AppLocalizations.of(context);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goToMainNavigation();
      },
      child: Scaffold(
        appBar: AppHeader(
          quantityNumber: false,
          prefixIcon: BackButtonWidget(
            onTap: _goToMainNavigation,
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
                : Center(
                    child: Text(localizations.translate('orderNotFound')),
                  ),
      ),
    );
  }
}
