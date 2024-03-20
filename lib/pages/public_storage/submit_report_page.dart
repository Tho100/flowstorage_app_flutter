import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

// ignore: must_be_immutable
class SubmitReportPage extends StatelessWidget {

  final String reportType;
  final String fileName;

  SubmitReportPage({
    required this.fileName,
    required this.reportType,
    Key? key
  }) : super(key: key);

  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  final isMyEntityNotifier = ValueNotifier<bool>(false); 
  final isNotMyEntityNotifier = ValueNotifier<bool>(false);

  final violationReport = {"cv","tv","pv"};

  Widget buildBody() {

    const reportTypeToFull = {
      "cv": "Copyright Violation",
      "tv": "Trademark Violation",
      "pv": "Privacy Violation",
      "sp": "Spam",
      "ma": "Malware"
    };

    const violationToQuestion = {
      "cv": "Who does this copyright belong to?",
      "tv": "Who does this trademark belong to?",
      "pv": "Whose privacy is being violated?",
    };

    const reportTypeToDescription = {
      "cv": "Content that violates a copyright you own or control.",
      "tv": "Content that violates a trademark you own or control.",
      "pv": "Content related to someone's personal space or revealing \nprivate information without permission.",
      "sp": "Repeated content or unwanted actions.",
      "ma": "This content may contain potential malware."
    };

    final fileType = fileName.split('.').last;

    final isGeneralFile = Globals.generalFileTypes.contains(fileType);

    return Column(
      children: [

        const SizedBox(height: 5),

        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(reportTypeToFull[reportType]!,
              style: const TextStyle(
                color: ThemeColor.secondaryWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 13.0, top: 6),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(reportTypeToDescription[reportType]!,
              style: const TextStyle(
                color: ThemeColor.secondaryWhite,
                fontSize: 15,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        const Divider(color: ThemeColor.lightGrey, height: 2),

        const SizedBox(height: 5),

        Row(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image(
                      width: isGeneralFile ? 38 : 55,
                      height: isGeneralFile? 38 : 55,
                      fit: BoxFit.cover, 
                      image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                    ),
                  ),
                ),

                if(Globals.videoType.contains(fileName.split('.').last))
                const Padding(
                  padding: EdgeInsets.only(top: 22.0, left: 24.0),
                  child: VideoPlaceholderWidget(),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        ShortenText().cutText(fileName, customLength: 42),
                        style: const TextStyle(
                          color: ThemeColor.justWhite,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Uploaded by ${psStorageData.psUploaderList.elementAt(storageData.fileNamesFilteredList.indexOf(fileName))}",
                        style: const TextStyle(
                          color: ThemeColor.thirdWhite,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
            
          ],
        ),
        
        if(violationReport.contains(reportType)) ... [

        const SizedBox(height: 8),

        const Divider(color: ThemeColor.lightGrey, height: 2),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(violationToQuestion[reportType]!,
              style: const TextStyle(
                color: ThemeColor.secondaryWhite,
                fontSize: 21,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: CheckboxTheme(
            data: CheckboxThemeData(
              fillColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.darkGrey,
                ),
              checkColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.secondaryWhite,
                ),
              overlayColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.secondaryWhite.withOpacity(0.1),
                ),
              side: const BorderSide(
                  color: ThemeColor.lightGrey,
                  width: 2.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: isMyEntityNotifier,
                    builder: (context, value, child) {
                      return Checkbox(
                        value: value,
                        onChanged: (checkedValue) {
                          isMyEntityNotifier.value = checkedValue ?? true;
                          isNotMyEntityNotifier.value = false;
                        },
                      );
                    },
                  ),
                  const Text(
                    "Either yours or that of an individual or entity \nyou represent.",
                    style: TextStyle(
                      color: Color.fromARGB(225, 225, 225, 225),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: CheckboxTheme(
            data: CheckboxThemeData(
              fillColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.darkGrey,
                ),
              checkColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.secondaryWhite,
                ),
              overlayColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.secondaryWhite.withOpacity(0.1),
                ),
              side: const BorderSide(
                  color: ThemeColor.lightGrey,
                  width: 2.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: isNotMyEntityNotifier,
                    builder: (context, value, child) {
                      return Checkbox(
                        value: value,
                        onChanged: (checkedValue) {
                          isNotMyEntityNotifier.value = checkedValue ?? true;
                          isMyEntityNotifier.value = false;
                        },
                      );
                    },
                  ),
                  const Text(
                    "Someone's else.",
                    style: TextStyle(
                      color: Color.fromARGB(225, 225, 225, 225),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],

        const SizedBox(height: 5),

        const Divider(color: ThemeColor.lightGrey)

      ],
    );
  }

  Future<void> createNewReport(String uploaderName, String fileName) async {

    final encryptedFileName = EncryptionClass().encrypt(fileName);

    const query = "INSERT INTO ps_report_info VALUES (:issuer_name, :uploader_name, :file_name, :report_type, :encrypted_name)";

    final params = {
      'issuer_name': userData.username, 
      'uploader_name': uploaderName,
      'file_name': fileName,
      'encrypted_name': encryptedFileName,
      'report_type': reportType
    };

    await Crud().insert(query: query, params: params);

  }

  void processOnSubmit() async {

    try {

      final uploaderName = psStorageData.psUploaderList
        .elementAt(storageData.fileNamesFilteredList.indexOf(fileName));

      await createNewReport(uploaderName, fileName);

      CustomFormDialog.startDialog("Thank You", "Your report has been successfully submitted.");

    } catch (err) {
      CustomAlertDialog.alertDialog("Something went wrong.");
      return;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        title: "Submit a Report",
        actions: [
          TextButton(
            child: const Text("Submit",
                style: TextStyle(
                color: ThemeColor.darkPurple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {

              if(violationReport.contains(reportType) && !isMyEntityNotifier.value && !isNotMyEntityNotifier.value) {
                CustomAlertDialog.alertDialog("We need your input on the last question. Please choose at least one checkbox.");
                return;
              }

              processOnSubmit();

              Navigator.pop(context);

            }
          ),
        ]
      ).buildAppBar(),
      body: buildBody(),
    );
  }

}