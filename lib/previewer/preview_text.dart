import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/widgets/failed_load.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class PreviewText extends StatelessWidget {

  final TextEditingController controller;

  const PreviewText({
    Key? key, 
    required this.controller
  }) : super(key: key);

  Future<Uint8List> callTextDataAsync() async {

    final tempData = GetIt.instance<TempDataProvider>();

    try {
      
      if (tempData.origin != OriginFile.offline) {

        final fileData = await CallPreviewData().callDataAsync(
          tableNamePs: GlobalsTable.psText, 
          tableNameHome: GlobalsTable.homeText, 
          fileValues: Globals.textType
        );
        
        tempData.setFileData(fileData);

        return fileData;

      } else {
        return await OfflineMode().loadOfflineFileByte(tempData.selectedFileName);

      }

      
    } catch (err, st) {
      Logger().e("Exception from _callData {PreviewText}", err, st);
      return Future.value(Uint8List(0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: callTextDataAsync(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {        
          controller.text = utf8.decode(snapshot.data!);
          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: TextFormField(controller: controller,
            keyboardType: TextInputType.multiline,
              maxLines: null,
              style: GoogleFonts.roboto(
                color: const Color.fromARGB(255, 220, 220, 220),
                fontWeight: FontWeight.w500,
                fontSize: 17,
              ),
              decoration: const InputDecoration(
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
    );
  }

}