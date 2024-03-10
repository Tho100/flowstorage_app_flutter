import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';
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
    this.isFromIntentSharing = false,
    this.customFileDataBase64,
    Key? key
  }) : super(key: key);

  Future<Uint8List> callPDFDataAsync() async {

    final tempData = GetIt.instance<TempDataProvider>();

    try {

      if(isFromIntentSharing!) {
        return base64.decode(customFileDataBase64!);
      }

      final fileData = tempData.origin != OriginFile.offline
        ? await CallPreviewFileData(
            tableNamePs: GlobalsTable.psPdf, 
            tableNameHome: GlobalsTable.homePdf, 
            fileTypes: {"pdf"}
          ).callData()
        : await OfflineModel().loadOfflineFileByte(tempData.selectedFileName);

      tempData.setFileData(fileData);

      return fileData;

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