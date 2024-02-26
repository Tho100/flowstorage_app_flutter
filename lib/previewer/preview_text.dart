import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/interact_dialog/text_dialog/discard_changes_dialog.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/widgets/failed_load.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class PreviewText extends StatelessWidget {

  const PreviewText({Key? key}) : super(key: key);

  static final textController = TextEditingController();

  static bool isChangesSaved = false;
  static bool isChangesMade = false;

  Future<Uint8List> callTextDataAsync() async {

    final tempData = GetIt.instance<TempDataProvider>();

    try {
      
      if (tempData.origin != OriginFile.offline) {

        final fileData = await CallPreviewFileData(
          tableNamePs: GlobalsTable.psText, 
          tableNameHome: GlobalsTable.homeText, 
          fileValues: Globals.textType
        ).callData();
        
        tempData.setFileData(fileData);

        return fileData;

      } else {
        return await OfflineModel().loadOfflineFileByte(tempData.selectedFileName);

      }

      
    } catch (err, st) {
      Logger().e("Exception from _callData {PreviewText}", err, st);
      return Future.value(Uint8List(0));
    }
    
  }

  Future<bool> discardChangesConfirmation(BuildContext context) async {
    return await DiscardChangesDialog()
                    .buildConfirmationDialog(context);
  }

  void resetData() {
    isChangesMade = false;
    isChangesSaved = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        if(isChangesMade && !isChangesSaved) {
          resetData();
          return await discardChangesConfirmation(context);

        } else {
          resetData();
          return true;
          
        }

      },
      child: FutureBuilder<Uint8List>(
        future: callTextDataAsync(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {        
            textController.text = utf8.decode(snapshot.data!);
            return Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: TextFormField(
                onChanged: (text) {
                  isChangesMade = true;
                  isChangesSaved = false;
                },
                controller: textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: GoogleFonts.roboto(
                  color: const Color.fromARGB(255, 220, 220, 220),
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
                decoration: const InputDecoration(
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            );
    
          } else if (snapshot.hasError) {
            return const FailedLoad();
    
          } else {
            return const LoadingIndicator();
    
          }
        },
      ),
    );
  }
  
}