import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatelessWidget {

  const MainPage({Key? key}) : super(key: key);

  Widget buildButtons(BuildContext context) {
    return Column(
      children: [

        const SizedBox(height: 30),

        MainButton(
          text: "Sign In",
          minusWidth: 62,
          onPressed: () => NavigatePage.goToPageLogin(context),
        ),

        const SizedBox(height: 15),

        SizedBox(
          height: 68,
          width: MediaQuery.of(context).size.width-62,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),  
            backgroundColor: ThemeColor.justWhite,
            foregroundColor: ThemeColor.thirdWhite,
          ),
          onPressed: () => NavigatePage.goToPageRegister(context),
          child: Text("Create Account",
            style: GoogleFonts.inter(
              color: ThemeColor.darkBlack,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget buildHeaderText() {
    return Text("Flow your files anywhere.",
      style: GoogleFonts.poppins(
        color: ThemeColor.justWhite,
        fontSize: 45,
        fontWeight: FontWeight.w800,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget buildSubText() {
    return Text("Backup your photos and files \nsecurely on the cloud with \nFlowstorage",
      style: GoogleFonts.poppins(
        color: ThemeColor.secondaryWhite,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget buildBottomContainer(BuildContext context) {
    return Container(
      color: ThemeColor.darkBlack,
      width: MediaQuery.of(context).size.width,
      height: 205,
      child: buildButtons(context),
    );
  }

  Widget buildPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 115),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: buildHeaderText(),
        ),
        
        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: buildSubText(),
        ),
      
        const Spacer(),
        buildBottomContainer(context)

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4A03A4),
      body: buildPage(context)
    );
  }
  
}