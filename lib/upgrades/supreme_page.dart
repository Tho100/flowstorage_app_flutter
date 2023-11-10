import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SupremePage extends StatefulWidget {
  const SupremePage({super.key});

  @override
  State<SupremePage> createState() => SupremePageState();
}

class SupremePageState extends State<SupremePage> {

  late final WebViewController controller;
  final paymentUrl = "https://buy.stripe.com/test_4gw3f6dXr5C755SdQY";

  static DateTime? startTime;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(paymentUrl));
    onPageLoaded();
  }

  void onPageLoaded() {
    startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: ThemeColor.darkBlack,
        title: const Text(
          "Upgrade Plan"
        ),
      ),
     body: WebViewWidget(
      controller: controller,
     ),
    );
  }
}