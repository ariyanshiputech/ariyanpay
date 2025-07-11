import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ariyanpay/controllers/payment_controller.dart';
import 'package:ariyanpay/core/services/api_services.dart';
import 'package:ariyanpay/loadingwidget.dart';
import 'package:ariyanpay/utils/config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentURL;

  const PaymentScreen({
    super.key,
    required this.paymentURL,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _webViewController;
  final controller = Get.put(PaymentController());

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController for webview_flutter 4.x+
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigation,
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentURL));
  }

Future<NavigationDecision> _handleNavigation(NavigationRequest request) async {
  final url = request.url;

  if (url.startsWith(AppConfig.redirectURL)) {
    controller.isPaymentVerifying.value = true;

    Uri uri = Uri.parse(url);
    String invoiceId = uri.queryParameters['invoice_id'] ?? '';

    debugPrint('Invoice ID: $invoiceId');

    final response = await ApiServices.verifyPayment(
      invoiceId,
      context,
    );

    controller.isPaymentVerifying.value = false;

    if (mounted) {
      Navigator.pop(context, response);
    }

    return NavigationDecision.prevent;
  }

  if (url.startsWith(AppConfig.cancelURL)) {
    controller.isPaymentVerifying.value = false;

    if (mounted) {
      Navigator.pop(context);
    }

    return NavigationDecision.prevent;
  }

  return NavigationDecision.navigate;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: WebViewWidget(
                      controller: _webViewController,
                    ),
                  ),
                ],
              ),
              if (controller.isPaymentVerifying.value) ...[
                Container(
                  color: Colors.white.withOpacity(0.5),
                  child: const Center(
                    child: LoadingWidget(),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
