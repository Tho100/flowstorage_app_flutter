import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_query/retrieve_data.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/public_storage_query/get_uploader_name.dart';
import 'package:get_it/get_it.dart';

class CallPreviewFileData {

  final String tableNamePs;
  final String tableNameHome;
  final Set<dynamic> fileValues;

  CallPreviewFileData({
    required this.tableNameHome,
    required this.tableNamePs,
    required this.fileValues,
  });

  final retrieveData = RetrieveData();
  final uploaderName = UploaderName();

  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  Future<Uint8List> callData() async {

    final tableName = [OriginFile.public, OriginFile.publicSearching].contains(tempData.origin)
      ? tableNamePs 
      : tableNameHome;

    final uploaderUsername = [OriginFile.public, OriginFile.publicSearching].contains(tempData.origin)
      ? await uploaderName.getUploaderName(tableName: tableNamePs, fileValues: fileValues)
      : userData.username;

    return await retrieveData.retrieveDataParams(
      uploaderUsername,
      tempData.selectedFileName,
      tableName
    );
    
  }
  
}