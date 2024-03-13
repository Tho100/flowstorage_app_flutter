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
  final Set<String> fileTypes;

  CallPreviewFileData({
    required this.tableNameHome,
    required this.tableNamePs,
    required this.fileTypes,
  });

  final retrieveData = RetrieveData();
  final uploaderName = UploaderName();

  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  Future<Uint8List> callData() async {

    final isPublicStorage = [OriginFile.public, OriginFile.publicSearching].contains(tempData.origin);

    final tableName = isPublicStorage ? tableNamePs : tableNameHome;

    final uploaderUsername = isPublicStorage
      ? await uploaderName.getUploaderName(tableName: tableNamePs, fileTypes: fileTypes)
      : userData.username;

    return await retrieveData.getFileData(
      uploaderUsername,
      tempData.selectedFileName,
      tableName
    );
    
  }
  
}