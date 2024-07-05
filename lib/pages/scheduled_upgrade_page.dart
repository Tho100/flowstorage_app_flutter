import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduledUpgradePage extends StatefulWidget {

  const ScheduledUpgradePage({Key? key}) : super(key: key);

  @override
  State<ScheduledUpgradePage> createState() => ScheduledUpgradePageState();

}

class ScheduledUpgradePageState extends State<ScheduledUpgradePage> {

  final pageController = PageController();

  int currentPageIndex = 0;

  Widget buildCard({
    required BuildContext context,
    required String plan,
    required String subheader,
    required Color bgColor,
    double? customFontSize
  }) {
    return Container(
      width: MediaQuery.of(context).size.width-55,
      height: 510,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25)
      ),
      child: Column(
        children: [
 
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text("PLAN",  
              style: GoogleFonts.poppins(
                color: ThemeColor.darkGrey,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          Text(plan,  
            style: GoogleFonts.poppins(
              color: ThemeColor.darkGrey,
              fontSize: customFontSize ?? 60,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Text(subheader,  
              style: GoogleFonts.poppins(
                color: ThemeColor.darkGrey,
                fontSize: customFontSize ?? 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 55.0),
            child: Text("Cancel anytime.",  
              style: GoogleFonts.poppins(
                color: ThemeColor.lightGrey,
                fontSize: customFontSize ?? 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center
            ),
          ),

        ],
      ),
    );
  }

  Widget buildCardsListView(BuildContext context) {

    final plans = ["MAX", "EXPRESS", "SUPREME"];

    final subheaders = [
      "Upload up to 200 files \nand 5 folders!", 
      "Upload up to 800 files \nand 10 folders!",
      "Upload up to 2000 files \nand 20 folders!"
    ];
    
    const bgColors = [
      Color.fromARGB(255, 250, 225, 137),
      Color.fromARGB(255, 97, 166, 245),
      Color.fromARGB(255, 156, 85, 236),
    ];

    return SizedBox(
      width: MediaQuery.of(context).size.width-55,
      height: 510,
      child: Padding(
        padding: const EdgeInsets.only(top: 34.0),
        child: PageView.builder(
          controller: pageController,
          itemCount: 3,
          itemBuilder: (context, index) {
            return buildCard(
              context: context, 
              plan: plans[index], 
              subheader: subheaders[index], 
              bgColor: bgColors[index]
            );
          },
        ),
      ),
    );

  }

  Widget buildDot({bool isActive = false}) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget buildDotsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3, 
        (index) => buildDot(isActive: index == currentPageIndex),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [

          Text("Get a better Flowstorage",  
            style: GoogleFonts.poppins(
              color: ThemeColor.justWhite,
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),

          buildCardsListView(context),
          
          const SizedBox(height: 40),

          buildDotsRow(),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width-55,
              height: 65,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.justWhite,
                  foregroundColor: ThemeColor.thirdWhite,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  NavigatePage.goToPageUpgrade();
                },
                child: Text(
                  'See Plan',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: ThemeColor.darkBlack,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 26.0),
            child: SizedBox(
            width: MediaQuery.of(context).size.width-55,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColor.darkBlack,
                  foregroundColor: ThemeColor.thirdWhite,
                  shape: const StadiumBorder(),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Dismiss',
                    style:  GoogleFonts.poppins(
                    color: ThemeColor.secondaryWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  void onPageChanged() {
    setState(() {
      currentPageIndex = pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    pageController.addListener(onPageChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 45.0),
        child: buildBody(context),
      ),
    );
  }

}