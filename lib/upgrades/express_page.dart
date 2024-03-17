import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExpressPage extends StatefulWidget {
  const ExpressPage({super.key});

  @override
  State<ExpressPage> createState() => ExpressPageState();
}

class ExpressPageState extends State<ExpressPage> {

  late final WebViewController controller;
  final paymentUrl = "https://buy.stripe.com/test_eVaeXO9Hb6Gb2XK14b";

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
      appBar: CustomAppBar(
        context: context, 
        title: "Upgrade Plan"
      ).buildAppBar(),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}