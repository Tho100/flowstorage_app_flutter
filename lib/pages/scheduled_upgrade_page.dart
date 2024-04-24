import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduledUpgradePage extends StatelessWidget {

  const ScheduledUpgradePage({Key? key}) : super(key: key);

  Widget buildCard({
    required BuildContext context,
    required String plan,
    required String subheader,
    required Color planColor, 
    double? customFontSize
  }) {
    return Container(
      width: MediaQuery.of(context).size.width-55,
      height: 510,
      decoration: BoxDecoration(
        color: ThemeColor.justWhite,
        borderRadius: BorderRadius.circular(25)
      ),
      child: Column(
        children: [
 
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text("PLAN",  
              style: GoogleFonts.poppins(
                color: ThemeColor.mediumBlack,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),

          Text(plan,  
            style: GoogleFonts.poppins(
              color: planColor,
              fontSize: customFontSize ?? 60,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Text(subheader,  
              style: GoogleFonts.poppins(
                color: ThemeColor.mediumBlack,
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
    
    const planColors = [
      Color.fromARGB(255, 250, 195, 4),
      Color.fromARGB(255, 40, 100, 169),
      ThemeColor.darkPurple,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 34.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width-55,
        height: 510,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()
          ),
          itemCount: 3,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return buildCard(
              context: context, 
              plan: plans[index], 
              subheader: subheaders[index], 
              planColor: planColors[index]
            );
          }
        ),
      ),
    );

  }

  Widget buildDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: ThemeColor.thirdWhite,
        borderRadius: BorderRadius.circular(55)
      ),
    );
  }

  Widget buildDotsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildDot(),
        const SizedBox(width: 10),
        buildDot(),
        const SizedBox(width: 10),
        buildDot(),
      ]
    );
  }

  Widget buildBody(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 38.0),
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
            
            const SizedBox(height: 36),

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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    )
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
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("DISMISS",
                  style: GoogleFonts.poppins(
                    color: ThemeColor.secondaryWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: buildBody(context),
      ),
    );
  }

}