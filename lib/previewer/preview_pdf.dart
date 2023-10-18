import 'dart:async';
import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/call_preview_file_data.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/widgets/failed_load.dart';
import 'package:flowstorage_fsc/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;

class PreviewPdf extends StatelessWidget {

  PreviewPdf({Key? key}) : super(key: key);

  final tempData = GetIt.instance<TempDataProvider>();

  Future<Uint8List> callPDFDataAsync() async {

    try {

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
            return LoadingFile.buildLoading();

          } else if (snapshot.hasError) {
            return FailedLoad.buildFailedLoad();

          } else {
            return Transform(
              transform: Matrix4.rotationZ(math.pi),
              alignment: Alignment.center,
              child: PDFView(
                pdfData: snapshot.data!,
                swipeHorizontal: true,
                fitPolicy: FitPolicy.WIDTH,
                preventLinkNavigation: false,
              ),
            );

          }
        },
      ),
    );
  }

}