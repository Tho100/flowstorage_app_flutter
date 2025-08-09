import 'package:flowstorage_fsc/api/currency_converter_api.dart';
import 'package:flowstorage_fsc/data_query/update_account.dart';
import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/provider/temp_payment_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';

import 'package:flowstorage_fsc/upgrades/customers_dashboard.dart';
import 'package:flowstorage_fsc/upgrades/express_page.dart';
import 'package:flowstorage_fsc/upgrades/max_page.dart';
import 'package:flowstorage_fsc/upgrades/supreme_page.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/tab_bar.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class UpgradePage extends StatefulWidget {

  const UpgradePage({super.key});

  @override
  State<UpgradePage> createState() => UpgradePageState();

}

class UpgradePageState extends State<UpgradePage> {

  String userSelectedPlan = "";

  final userData = GetIt.instance<UserDataProvider>();
  final tempData = GetIt.instance<TempPaymentProvider>();

  final singleLoading = SingleTextLoading();

  final cardBorderRadius = 25.0;

  Widget _buildSubHeader(String text, {double? customFont}) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: ThemeColor.darkGrey,
        fontWeight: FontWeight.w600,
        fontSize: customFont ?? 15,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildFeatures(String text) {
    return Text(text,
      style: GoogleFonts.poppins(
        color: ThemeColor.mediumBlack,
        fontWeight: FontWeight.w600,
        fontSize: 20
      ),
      maxLines: 1,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildCurrentPlanText() {
    return Text(
      "YOUR CURRENT PLAN",
      style: GoogleFonts.poppins(
        color: const Color.fromARGB(255, 18, 18, 18),
        fontWeight: FontWeight.w600,
        fontSize: 18
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildSubscribeButton(String plan, VoidCallback subscribeOnPressed) {

    final isCurrentPlan = plan == userData.accountType;

    return isCurrentPlan 
    ? _buildCurrentPlanText()
    : SizedBox(
      width: MediaQuery.of(context).size.width-55,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkBlack,
          shape: const StadiumBorder(),
        ),
        onPressed: subscribeOnPressed,
        child: Text(
          'Subscribe',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
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
              color: const Color.fromARGB(255, 15, 15, 15),
              fontWeight: FontWeight.w600,
              fontSize: 28
            ),
            textAlign: TextAlign.left,
          );

        } else if (priceSnapshot.hasData) {
          final price = priceSnapshot.data!;
          final indexOfDot = price.indexOf('.');
          final actualPrice = price.substring(0, indexOfDot);
          return Text("$actualPrice/mo.",
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 15, 15, 15),
              fontWeight: FontWeight.w600,
              fontSize: 28
            ),
            textAlign: TextAlign.left,
          );

        } else {
          return Text("\$$value/mo.",
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 15, 15, 15),
              fontWeight: FontWeight.w600,
              fontSize: 28
            ),
            textAlign: TextAlign.left,
          );

        }
      } 
    );
  }

  Widget _buildMaxPage(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [

          const SizedBox(height: 34),
        
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height-180,
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
                            color: const Color.fromARGB(255, 250, 195, 4),
                            fontWeight: FontWeight.w600,
                            fontSize: 28
                          ),
                          textAlign: TextAlign.left,
                        ),

                      ],
                    ),

                    const SizedBox(width: 50),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("PRICE"),
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
                  child: _buildSubscribeButton("Max", () {
                    _subscribeOnPressed("Max");
                  }),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: _buildSubHeader(userData.accountType == "Max" ? "" : "Cancel anytime without extra charges", customFont: 13)
                ),

                const SizedBox(height: 35),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget _buildExpressPage(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [

          const SizedBox(height: 34),
        
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
                            color: const Color.fromARGB(255, 40, 100, 169),
                            fontWeight: FontWeight.w600,
                            fontSize: 28
                          ),
                          textAlign: TextAlign.left,
                        ),

                      ],
                    ),

                    const SizedBox(width: 50),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("PRICE"),
                        _buildPrice(8),
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
                  child: _buildSubscribeButton("Express", () {
                    _subscribeOnPressed("Express");
                  }),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: _buildSubHeader(userData.accountType == "Express" ? "" : "Cancel anytime without extra charges", customFont: 13)
                ),

                const SizedBox(height: 35),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget _buildSupremePage(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [

          const SizedBox(height: 34),
        
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
                            color: ThemeColor.darkPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: 28
                          ),
                          textAlign: TextAlign.left,
                        ),

                      ],
                    ),

                    const SizedBox(width: 50),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeader("PRICE"),
                        _buildPrice(20),
                      ],
                    ),

                  ],
                ),

                const SizedBox(height: 25),

                Row(
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
                  child: _buildSubscribeButton("Supreme", () {
                    _subscribeOnPressed("Supreme");
                  }),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.center,
                  child: _buildSubHeader(userData.accountType == "Supreme" ? "" : "Cancel anytime without extra charges", customFont: 13)
                ),

                const SizedBox(height: 35),

              ],
            ),
          ),
        ],
      ),        
    );
  }

  Widget _buildTabUpgrade() {

    final cardHeight = MediaQuery.of(context).size.height-180;
    final cardWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [

          CustomTabBar(
            tabs: [
              Tab(
                child: Text(
                  'Max',
                  style: GlobalsStyle.tabBarTextStyle,
                ),
              ),
              Tab(
                child: Text(
                  'Express',
                  style: GlobalsStyle.tabBarTextStyle,
                ),
              ),
              Tab(
                child: Text(
                  'Supreme',
                  style: GlobalsStyle.tabBarTextStyle,
                ),
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [
                _buildMaxPage(cardWidth, cardHeight),
                _buildExpressPage(cardWidth, cardHeight),
                _buildSupremePage(cardWidth, cardHeight),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  void _subscribeOnPressed(String type) {

    if (_userIsAlreadySubscribed()) {
      return;
    }

    userSelectedPlan = type.toLowerCase();

    switch (type) {
      case "Max":
        _navigateToPage(const MaxPage(), "Max");
        break;
      case "Express":
        _navigateToPage(const ExpressPage(), "Express");
        break;
      case "Supreme":
        _navigateToPage(const SupremePage(), "Supreme");
        break;
    }

  }

  void _navigateToPage(Widget page, String plan) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => page))
        .then((value) {
      _validatePaymentOnTime(plan);
    });
  }

  void _validatePaymentOnTime(String planType) async {

    DateTime endTime = DateTime.now();
    Duration? timeSpent;

    switch(planType) {
      case "Max":
        timeSpent = endTime.difference(MaxPageState.startTime!);
        break;

      case "Express":
        timeSpent = endTime.difference(ExpressPageState.startTime!);
        break;

      case "Supreme":
        timeSpent = endTime.difference(SupremePageState.startTime!);
        break;
    }

    if (timeSpent!.inSeconds > 10) {
      await _validatePayment();
    }

  }

  Future<String> _convertToLocalCurrency(double usdValue) async {
    return await CurrencyConverterApi().convert(
      usdValue: usdValue, isFromMyPlan: false
    );
  }

  Future<void> _validatePayment() async {

    try {

      singleLoading.startLoading(title: "Validating...", context: context);

      final returnedEmail = await StripeCustomers(customerEmail: '').getCustomersEmails();

      singleLoading.stopLoading();

      if(!returnedEmail.contains(userData.email)) {
        CustomAlertDialog.alertDialogTitle("Payment failed", "No payment has been made.");
        return;
      }
        
      if(mounted) {
        singleLoading.startLoading(title: "Upgrading...", context: context);
      }

      await _initializeNewAccountPlan();

      singleLoading.stopLoading();

      CallNotify().customNotification(
        title: "Account Upgraded", 
        subMessage: "Thank you for subscribing to our service! You subscribed for $userSelectedPlan plan"
      );

      CustomAlertDialog.alertDialogTitle(
        "Account Upgraded", 
        "You've subscribed to Flowstorage $userSelectedPlan account plan."
      );

      returnedEmail.clear();

    } catch (err) {
      singleLoading.stopLoading();
    }
    
  }

  Future<void> _initializeNewAccountPlan() async {

    final currentUserCustomerId = await StripeCustomers(
      customerEmail: userData.email
    ).getCustomerIdByEmail();

    await UpdateAccount(
      customerId: currentUserCustomerId, 
      selectdPlan: userSelectedPlan
    ).updateUserAccountPlan().then(
      (_) => userData.setAccountType(userSelectedPlan)
    );

    await _updateLocalDataOnSubscribed();

  }

  Future<void> _updateLocalDataOnSubscribed() async {

    await LocalStorageModel().setupLocalAutoLogin(
      userData.username, userData.email, userSelectedPlan);

    final readLocalUsernames = await LocalStorageModel()
      .readLocalAccountUsernames();

    final usernameIndex = readLocalUsernames.indexOf(userData.username);

    await LocalStorageModel().updateLocalPlans(
      usernameIndex, userSelectedPlan);

  }

  bool _userIsAlreadySubscribed() {

    if(userData.accountType != "Basic") {
      CustomAlertDialog.alertDialogTitle(
        "Subscription Failure",
        "Unable to subscribe. To proceed with this plan, please cancel your current subscription."
      );

      return true;

    }

    return false;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: CustomAppBar(
        context: context, 
        title: "Upgrade Plan"
      ).buildAppBar(),
      body: _buildTabUpgrade(),
    );
  }

}