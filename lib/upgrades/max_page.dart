import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MaxPage extends StatefulWidget {

  const MaxPage({Key? key}) : super(key: key);

  @override
  State<MaxPage> createState() => MaxPageState();
}

class MaxPageState extends State<MaxPage> {

  late final WebViewController controller;
  final paymentUrl = 'https://buy.stripe.com/test_14k16Y5qVfcH9m88wC';

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