import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class AddPasscodePage extends StatefulWidget {

  final bool isFromConfigurePasscode;

  const AddPasscodePage({
    required this.isFromConfigurePasscode,
    Key? key
  }) : super(key: key);

  @override
  State<AddPasscodePage> createState() => AddPasscodePageState();

}

class AddPasscodePageState extends State<AddPasscodePage> {

  final logger = Logger();

  final controllers = List.generate(4, (_) => TextEditingController());
  final focusNodes = List.generate(4, (_) => FocusNode());

  int currentActiveField = 0;

  Future<void> addPassCode() async {

    const storage = FlutterSecureStorage();

    final passCode = controllers.map((controller) => controller.text).join();

    await storage.write(key: "key0015", value: passCode);
    await storage.write(key: "isEnabled", value: "true");

    CallToast.call(message: "Passcode added.");

    for (final controller in controllers) { 
      controller.clear();
    }

    if(mounted) {
      NavigatePage.permanentPageHome(context);
    }

  }

  void cancelPassCode() {
    for (final controller in controllers) { 
      controller.clear();
    }
    NavigatePage.permanentPageHome(context);
  }

  void processInput() async {

    try {

      CustomAlertDialog.alertDialogCustomOnPressed(
        messages: "Confirm passcode?", 
        oPressedEvent: () async { 
          Navigator.pop(context);
          await addPassCode();
          return;
        }, 
        onCancelPressed: () {
          cancelPassCode();
          return;
        },
        context: context
      );

    } catch (err, st) {
      logger.e("Exception from validatePassCode {PasscodePage}",err, st);
    }
    
  }

  Widget buildAddPasscodePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        const SizedBox(height: 75),

        Center(
          child: Text(
            widget.isFromConfigurePasscode 
              ? "Edit passcode" : "Add new passcode",
            style: GoogleFonts.inter(
              color: ThemeColor.darkPurple,
              fontSize: 21,
              fontWeight: FontWeight.w800
            ),
          ),
        ),

        const SizedBox(height: 70),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: SizedBox(
                width: 55,
                height: 55,
                child: TextFormField(
                  style: GoogleFonts.inter(
                    fontSize: 23, 
                    color: ThemeColor.darkPurple,
                    fontWeight: FontWeight.w800,
                  ),
                  readOnly: true,
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: GlobalsStyle.setupPasscodeFieldDecoration(),
                  onChanged: (value) {

                    if (value.isNotEmpty) {
                      if (index < 3) {
                        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                        currentActiveField = index + 1;
                      } else {
                        processInput();
                        focusNodes[index].unfocus();
                      }

                    } else {
                      controllers[index].clear();
                      if (index > 0) {
                        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                        currentActiveField = index - 1;
                      }

                    }

                  },
                ),
              ),
            ),
          ),
        ),

        const Spacer(),

        const SizedBox(height: 125),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildButtons("1", ""),
            buildButtons("2", "ABC"),
            buildButtons("3", "DEF"),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildButtons("4", "GHI"),
            buildButtons("5", "JKL"),
            buildButtons("6", "MNO"),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildButtons("7", "PQRS"),
            buildButtons("8", "TUV"),
            buildButtons("9", "WXYZ"),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildButtons("", ""),
            buildButtons("0", "*"),
            buildEraseButton(),
          ],
        ),

        const Spacer(),

      ],
    );
  }

  Widget buildEraseButton() {
    return SizedBox(
      width: 82,
      height: 82,
      child: IconButton(
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
        ),
        padding: EdgeInsets.zero,
        onPressed: () => updateBackSpace(),
        icon: const Icon(Icons.backspace_rounded, size: 30, color: ThemeColor.justWhite),
      ),
    );
  }

  Widget buildButtons(String input, String bottomInput) {
    return SizedBox(
      width: 82,
      height: 82,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: ThemeColor.darkBlack,
          elevation: 0,
          padding: EdgeInsets.zero
        ),
        onPressed: () {
          setState(() {
            updateCurrentFieldText(input);
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              input,
              style: GoogleFonts.inter(
                color: ThemeColor.justWhite,
                fontSize: 33,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              bottomInput,
              style: GoogleFonts.inter(
                color: ThemeColor.thirdWhite,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  void updateBackSpace() {
    
    controllers[currentActiveField].clear();

    if (currentActiveField > 0) {
      FocusScope.of(context).requestFocus(focusNodes[currentActiveField - 1]);
      currentActiveField--;
    }

  }

  void updateCurrentFieldText(String text) {

    controllers[currentActiveField].text = text;
    if (currentActiveField < 3) {
      FocusScope.of(context).requestFocus(focusNodes[currentActiveField + 1]);
      currentActiveField++;

    } else {
      processInput();
      focusNodes[currentActiveField].unfocus();

    }

  }

  @override 
  void dispose() {
    for(final controller in controllers) {
      controller.dispose();
    }

    for(final node in focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack
      ),
      body: buildAddPasscodePage()
    );
  }

}