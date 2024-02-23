import 'dart:convert';

import 'package:flowstorage_fsc/api/geographic_api.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/upgrades/customers_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MyPlanPage extends StatefulWidget {

  const MyPlanPage({super.key});

  @override
  State<MyPlanPage> createState() => MyPlanPageState();
}

class MyPlanPageState extends State<MyPlanPage> {

  final userData = GetIt.instance<UserDataProvider>();

  final cardBorderRadius = 25.0;

  Future<String> _convertToLocalCurrency(double usdValue) async {

    final countryCodeToCurrency = {
      "US": "USD",
      "DE": "EUR",
      "GB": "GBP",
      "ID": "IDR",
      "MY": "MYR",
      "BN": "BND",
      "SG": "SGD",
      "TH": "THB",
      "PH": "PHP",
      "VN": "VND",
      "CN": "CNY",
      "HK": "HKD",
      "TW": "TWD",
      "KO": "KRW",
      "BR": "BRL",
      "ME": "MXN",
      "AU": "AUD",
      "NZ": "NZD",
      "IN": "INR",
      "LK": "LKR",
      "PA": "PKR",
      "SA": "SAR",
      "AR": "AED",
      "IS": "ILS",
      "EG": "EGP",
      "TU": "TND",
      "CH": "CHF",
      "ES": "EUR",
      "SW": "SEK"
    };

    String countryCode = 'US';
    String countryCurrency = 'USD';
    double conversionRate = 2.0;

    countryCode = await GeographicsApi().countryCode();
    countryCurrency = countryCodeToCurrency[countryCode]!;

    final response = await http.get(Uri.parse('https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_2N9mYDefob9ZEMqWT3cXAjl964IFfNkPMr01YS5v'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      conversionRate = data['data'][countryCurrency]; 
      
    } else {
      throw Exception('Failed to load exchange rates');

    }

    return ("$countryCurrency${usdValue*conversionRate}").toString();

  }

  Widget _buildSubHeader(String text, {double? customFont}) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: const Color.fromARGB(255, 18, 18, 18),
          fontWeight: FontWeight.w600,
          fontSize: customFont ?? 15,
        ),
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildFeatures(String text) {
    return Text(text,
      style: GoogleFonts.poppins(
        textStyle: const TextStyle(
          color: Color.fromARGB(255, 15, 15, 15),
          fontWeight: FontWeight.w600,
          fontSize: 20
        ),
      ),
      maxLines: 1,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildCancelPlanButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width-55,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )
        ),
        onPressed: () {
          CustomAlertDialog.alertDialogCustomOnPressed(
            messages: "Are you sure you want to cancel your subscription plan? \n\nYour account will downgraded to Basic from ${userData.accountType} and you'll no longer be charged.", 
            oPressedEvent: () async {

              try {

                await StripeCustomers.
                cancelCustomerSubscriptionByEmail(userData.email, context);

                if(mounted) {
                  Navigator.pop(context);
                }

                CustomAlertDialog.alertDialogTitle(
                  "Subscription plan cancelled successfully", 
                  "Thank you for being previously a part of our customer!"
                );

              } catch (er) {
                SnakeAlert.errorSnake("Subscription cancellation failed.");
                return;
              }

            }, 
            onCancelPressed: () {
              Navigator.pop(context);
            }, 
            context: context
          );
        },
        child: const Text(
          'Cancel Plan',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ThemeColor.justWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildPrice(double value) {

    return FutureBuilder<String>(
      future: _convertToLocalCurrency(value),
      builder: (context, priceSnapshot) {
        if(priceSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(color: ThemeColor.darkBlack)
          );
        } else if (priceSnapshot.hasError) {
          return Text("\$$value/mo.",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                color: Color.fromARGB(255, 15, 15, 15),
                fontWeight: FontWeight.w600,
                fontSize: 28
              ),
            ),
            textAlign: TextAlign.left,
          );
        } else if (priceSnapshot.hasData) {
          final price = priceSnapshot.data!;
          final indexOfDot = price.indexOf('.');
          final actualPrice = price.substring(0, indexOfDot);
          return Text("$actualPrice/mo.",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                color: Color.fromARGB(255, 15, 15, 15),
                fontWeight: FontWeight.w600,
                fontSize: 28
              ),
            ),
            textAlign: TextAlign.left,
          );
        } else {
          return Text("\$$value/mo.",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                color: Color.fromARGB(255, 15, 15, 15),
                fontWeight: FontWeight.w600,
                fontSize: 28
              ),
            ),
            textAlign: TextAlign.left,
          );
        }
      } 
    );
  }

  Widget buildHeader(String typeTag, String priceTag, String featuresTag) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          typeTag,
          style: const TextStyle(
            color: ThemeColor.justWhite,
            fontWeight: FontWeight.w700,
            fontSize: 45
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 5),
        Text(
          "Charged \$$priceTag monthly",
          style: const TextStyle(
            color: ThemeColor.darkBlack,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 22),
        const Text(
          "FEATURES",
          style: TextStyle(
            color: ThemeColor.justWhite,
            fontSize: 16,
            fontWeight: FontWeight.w900
          ),
        ),
        const SizedBox(height: 5),
        Text(
          featuresTag,
          style: const TextStyle(
            color: ThemeColor.darkBlack,
            fontSize: 16,
            fontWeight: FontWeight.w900
          ),
        ),
      ],
    );
  }

  Widget buildMaxPage(double width, double height) {

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
        
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cardBorderRadius), 
                topRight: Radius.circular(cardBorderRadius)
              ),
              color: ThemeColor.justWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 30),

                Row(
                  children: [
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("PLAN"),
                        Text("MAX",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 250, 195, 4),
                              fontWeight: FontWeight.w600,
                              fontSize: 28
                            ),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const SizedBox(width: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("CHARGED"),
                        _buildPrice(3)
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Row( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 30),
                    Column(  
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("FEATURES"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 150 Files"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 5 Folders"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Unlocked Folder Download"),
                      ],
                    ),
                  ],
                ), 
                
                const Spacer(),

                Align(
                  alignment: Alignment.center,
                  child: _buildCancelPlanButton(),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: _buildSubHeader("Your fees will be paid automatically when you cancel.", customFont: 13)
                ),

                const SizedBox(height: 35),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget buildExpressPage(double width, double height) {

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
        
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cardBorderRadius), 
                topRight: Radius.circular(cardBorderRadius)
              ),
              color: ThemeColor.justWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 30),

                Row(
                  children: [
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("PLAN"),
                        Text("EXPRESS",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 40, 100, 169),
                              fontWeight: FontWeight.w600,
                              fontSize: 28
                            ),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const SizedBox(width: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("CHARGED"),
                        _buildPrice(8)
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Row( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 30),
                    Column(  
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("FEATURES"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 800 Files"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 10 Folders"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Unlocked Folder Download"),
                      ],
                    ),
                  ],
                ), 
                
                const Spacer(),

                Align(
                  alignment: Alignment.center,
                  child: _buildCancelPlanButton(),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: _buildSubHeader("Your fees will be paid automatically when you cancel.", customFont: 13)
                ),

                const SizedBox(height: 35),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget buildSupremePage(double width, double height) {

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
        
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cardBorderRadius), 
                topRight: Radius.circular(cardBorderRadius)
              ),
              color: ThemeColor.justWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 30),

                Row(
                  children: [
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("PLAN"),
                        Text("SUPREME",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color.fromARGB(255, 74, 3, 164),
                              fontWeight: FontWeight.w600,
                              fontSize: 28
                            ),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const SizedBox(width: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("CHARGED"),
                        _buildPrice(20)
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Row( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 30),
                    Column(  
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("FEATURES"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 2000 Files"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 20 Folders"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Upload Up To 5 Directories"),
                        const SizedBox(height: 5),
                        _buildFeatures("+ Unlocked Folder Download"),
                      ],
                    ),
                  ],
                ), 
                
                const Spacer(),

                Align(
                  alignment: Alignment.center,
                  child: _buildCancelPlanButton(),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: _buildSubHeader("Your fees will be paid automatically when you cancel.", customFont: 13)
                ),

                const SizedBox(height: 35),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height-115;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        title: const Text(
          "My plan",
          style: GlobalsStyle.appBarTextStyle
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 35),

            if(userData.accountType == "Max") 
            buildMaxPage(width, height),

            if(userData.accountType == "Express") 
            buildExpressPage(width, height),

            if(userData.accountType == "Supreme") 
            buildSupremePage(width, height),

          ],
        ),
      ),
    );
  }
}