import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String titleKey;
  final double fem;
  final Function(Locale) setLocale;
  final bool userSignedIn;
  final Locale currentLocale;

  const WebViewPage({
    Key? key,
    required this.url,
    required this.titleKey,
    required this.fem,
    required this.setLocale,
    required this.userSignedIn,
    required this.currentLocale,
  }) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppHeader(
        quantityNumber: false,
        title: widget.titleKey,
        fem: widget.fem,
        prefixIcon: BackButtonWidget(
          onTap: () => Navigator.pop(context),
        ),
        onPrefixIconTap: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
