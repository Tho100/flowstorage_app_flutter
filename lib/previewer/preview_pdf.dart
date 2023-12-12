import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/widgets/failed_load.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PreviewPdf extends StatelessWidget {

  final bool? isFromIntentSharing;
  final String? customFileDataBase64;

  const PreviewPdf({
    this.isFromIntentSharing,
    this.customFileDataBase64,
    Key? key
  }) : super(key: key);

  Future<Uint8List> callPDFDataAsync() async {

    final tempData = GetIt.instance<TempDataProvider>();

    try {

      if(isFromIntentSharing!) {
        final decodeData = base64.decode(customFileDataBase64!);
        return decodeData;

      }

      if(tempData.origin != OriginFile.offline) {
        final fileData = await CallPreviewData().callDataAsync(
          tableNamePs: GlobalsTable.psPdf, 
          tableNameHome: GlobalsTable.homePdf, 
          fileValues: {"pdf"}
        );

        tempData.setFileData(fileData);

        return fileData;

      } else {
        return await OfflineMode().loadOfflineFileByte(tempData.selectedFileName);

      }

    } catch (err, st) {
      Logger().e("Exception from _callData {PreviewPdf}", err, st);
      return Future.value(Uint8List(0));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<Uint8List>(
        future: callPDFDataAsync(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();

          } else if (snapshot.hasError) {
            return const FailedLoad();

          } else {
            return SfPdfViewer.memory(
              snapshot.data!,
              enableDoubleTapZooming: true,
              enableTextSelection: true,
            );
          
          }
        },
      ),
    );
  }

}