import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/data_classes/user_data_getter.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/models/quick_actions_model.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/just_loading.dart';
import 'package:flowstorage_fsc/folder_query/folder_name_retriever.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';

class PasscodePage extends StatefulWidget {

  const PasscodePage({super.key});

  @override
  State<PasscodePage> createState() => PasscodePageState();
}

class PasscodePageState extends State<PasscodePage> {

  final logger = Logger();

  final isButtonsEnabledNotifier = ValueNotifier<bool>(true);
  final isPasscodeIncorrectNotifier = ValueNotifier<bool>(false);

  final controllers = List.generate(4, (_) => TextEditingController());
  final focusNodes = List.generate(4, (_) => FocusNode());

  final accountInformationRetriever = UserDataGetter();

  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  final crud = Crud();

  int currentActiveField = 0;
  int totalAttempts = 0;

  void disableButtons() {
    isButtonsEnabledNotifier.value = false;
  }

  Future<void> getStartupDataFiles(MySQLConnectionPool conn, String savedCustUsername,String savedCustEmail, String savedAccountType) async {

    try {
      
      userData.setUsername(savedCustUsername);
      userData.setEmail(savedCustEmail);

      final accountType = await accountInformationRetriever
        .getAccountType(email: savedCustEmail, conn: conn);
      
      userData.setAccountType(accountType);

      final futures = await DataCaller().getStartupData(
        conn: conn, username: savedCustUsername);

      final results = await Future.wait(futures);

      final fileNames = <String>{};
      final bytes = <Uint8List>{};
      final dates = <String>[];

      final foldersList = <String>{};

      if (await crud.countUserTableRow(GlobalsTable.folderUploadTable) > 0) {
        foldersList.addAll(await FolderRetriever().getFolderName(savedCustUsername));
      }

      for (final result in results) {
        final fileNamesForTable = result[0] as List<String>;
        final bytesForTable = result[1] as List<Uint8List>;
        final datesForTable = result[2] as List<String>;

        fileNames.addAll(fileNamesForTable);
        bytes.addAll(bytesForTable);
        dates.addAll(datesForTable);
      }

      storageData.setFilesName(fileNames.toList());
      storageData.setImageBytes(bytes.toList());
      storageData.setFilesDate(dates);

      tempStorageData.setFoldersName(foldersList.toList());
      
      tempData.setOrigin(OriginFile.home);

    } catch (err) {
      NavigatePage.permanentPageHome(context);
      return;
    }

  }

  void validatePassCode(List<String> inputs) async {

    try {

      const storage = FlutterSecureStorage();
      String? storedValue = await storage.read(key: 'key0015');
      String userInput = "";

      for(final input in inputs) {
        userInput += input;
      }

      totalAttempts++;

      if(userInput == storedValue) {

        isPasscodeIncorrectNotifier.value = false;
        isButtonsEnabledNotifier.value = true;

        final conn = await SqlConnection.initializeConnection();

        final justLoading = JustLoading();

        if(mounted) {
          justLoading.startLoading(context: context);
        }

        tempData.origin == OriginFile.offline 
        ? await QuickActionsModel().offline()
        : await getStartupDataFiles(
          conn, userData.username, userData.email, userData.accountType);

        justLoading.stopLoading();
        
        if(mounted) {
          NavigatePage.permanentPageHome(context);
        }

      } else {        
        isPasscodeIncorrectNotifier.value = true;
        disableButtonsOnFailed5Attempts();

      }

    } catch (err, st) {
      NavigatePage.replacePageMain(context);
      logger.e("Exception from validatePassCode {PasscodePage}",err, st);
    } 

  }

  void disableButtonsOnFailed5Attempts() {
    if(totalAttempts == 5) {
      disableButtons();
      CallToast.call(message: "Passcode has been locked.");
    }
  }

  void processInput() {

    List<String> inputs = [];

    for (final controller in controllers) {
      inputs.add(controller.text);
    }

    validatePassCode(inputs);

    for (final controller in controllers) { 
      controller.clear();
    }

    currentActiveField = 0;

  }

  Widget buildPassCode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        const SizedBox(height: 30),

        const Icon(Icons.lock, color: ThemeColor.darkPurple),

        const SizedBox(height: 25),

        Center(
          child: Text(
            "Enter passcode",
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 55,
                height: 55,
                child: TextFormField(
                  style: GoogleFonts.inter(
                    fontSize: 23, 
                    color: ThemeColor.darkPurple,
                    fontWeight: FontWeight.w800,
                  ),
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  obscureText: true,
                  obscuringCharacter: '*',
                  readOnly: true,
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

        const SizedBox(height: 25),
      
        ValueListenableBuilder(
          valueListenable: isPasscodeIncorrectNotifier,
          builder: (context, value, child) {
            return Visibility(
              visible: value,
              child: Center(
                child: Text(
                  "Passcode is incorrect",
                  style: GoogleFonts.inter(
                    color: ThemeColor.darkRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w800
                  ),
                ),
              ),
            );
          },
        ),

        const Spacer(),

        const SizedBox(height: 100),

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

          if(!isButtonsEnabledNotifier.value) {
            CallToast.call(message: "Passcode has been locked.");
            return;
          }

          !isButtonsEnabledNotifier.value
          ? null 
          : setState(() {
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

    isButtonsEnabledNotifier.dispose();
    isPasscodeIncorrectNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack
      ),
      body: buildPassCode()
    );
  }
  
}