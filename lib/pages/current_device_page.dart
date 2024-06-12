import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BluetoothCurrentDevicePage extends StatelessWidget {
  
  final String deviceName;

  const BluetoothCurrentDevicePage({
    required this.deviceName,
    Key? key
  }) : super(key: key);

  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, bottom: 55.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              const Icon(Icons.bluetooth, color: ThemeColor.darkGrey, size: 18),

              Text("CURRENT DEVICE",
                style: GoogleFonts.poppins(
                  color: ThemeColor.darkGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14
                ),
                textAlign: TextAlign.left,
              ),

            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(deviceName,
              style: GoogleFonts.poppins(
                color: ThemeColor.darkBlack,
                fontWeight: FontWeight.w700,
                fontSize: 45
              ),
              textAlign: TextAlign.left,
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.justWhite,
      appBar: CustomAppBar(
        backgroundColor: ThemeColor.justWhite,
        leadingColor: ThemeColor.darkBlack,
        context: context, 
        title: ""
      ).buildAppBar(),
      body: buildBody(),
    );
  }
  
}