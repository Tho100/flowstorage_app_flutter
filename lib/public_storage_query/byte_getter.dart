import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/public_storage_query/thumbnail_getter.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class ByteGetterPs {

  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  final thumbnailGetter = ThumbnailGetterPs();

  final tableNameToAssetsImage = {
    GlobalsTable.psText: "txt0.jpg",
    GlobalsTable.psPdf: "pdf0.jpg",
    GlobalsTable.psAudio: "music0.jpg",
    GlobalsTable.psExcel: "exl0.jpg",
    GlobalsTable.psPtx: "pptx0.jpg",
    GlobalsTable.psExe: "exe0.jpg",
    GlobalsTable.psWord: "doc0.jpg",
    GlobalsTable.psMsi: "exe0.jpg",
    GlobalsTable.psApk: "apk0.jpg"
  };

  Future<List<Uint8List>> getFileData(MySQLConnectionPool conn, String tableName) async {

    if (tableName == GlobalsTable.psImage) {

      if(psStorageData.psImageBytesList.isEmpty) {
        return getFileInfoParams(conn, false);
      } 

      return psStorageData.psImageBytesList;

    }
    
    return getOtherTableParams(conn, tableName, isFromMyPs: false);

  }

  Future<List<Uint8List>> getMyFileData(MySQLConnectionPool conn, String tableName) async {
    
    if (tableName == GlobalsTable.psImage) {

      if(psStorageData.myPsImageBytesList.isEmpty) {
        return getFileInfoParams(conn, true);
      } 

      return psStorageData.myPsImageBytesList;

    } else {
      return getOtherTableParams(conn, tableName, isFromMyPs: true);
      
    }

  }

  Future<List<Uint8List>> getFileInfoParams(MySQLConnectionPool conn, bool isFromMyPs) async {

    final String query; 
    final IResultSet results;

    if(isFromMyPs) {
      query = 'SELECT CUST_FILE FROM ${GlobalsTable.psImage} WHERE CUST_USERNAME = :username ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';
      final params = {'username': userData.username};

      results = await conn.execute(query,params);

    } else {
      query = 'SELECT CUST_FILE FROM ${GlobalsTable.psImage} ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';
      results = await conn.execute(query);

    }
    
    final bytesData = results.rows.map((row) {
      final encryptedFile = row.assoc()['CUST_FILE']!;
      final decodedFile = base64.decode(EncryptionClass().decrypt(encryptedFile));

      final buffer = ByteData.view(decodedFile.buffer);
      return Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

    }).toList();
    
    isFromMyPs 
      ? psStorageData.setMyPsImageBytes(bytesData)
      : psStorageData.setPsImageBytes(bytesData);

    return bytesData;

  }

  Future<List<Uint8List>> getOtherTableParams(
    MySQLConnectionPool conn, 
    String tableName, 
    {required bool isFromMyPs}
  ) async {
    
    final getByteValue = <Uint8List>{};

    retrieveValue(String iconName) async {
      
      final String query;
      final IResultSet executedRows;
      
      if(isFromMyPs) {
        query = 'SELECT COUNT(*) FROM $tableName WHERE CUST_USERNAME = :username';
        final params = {'username': userData.username};

        executedRows = await conn.execute(query,params);

      } else {
        query = 'SELECT COUNT(*) FROM $tableName';
        executedRows = await conn.execute(query);

      }

      int totalCount = 0;

      for(final row in executedRows.rows) {
        totalCount = row.typedColAt<int>(0)!;
      }

      final loadImg = await Future.wait(List.generate(totalCount, (_) => GetAssets().loadAssetsData(iconName)));
      getByteValue.addAll(loadImg);

    }

    if (tableName == GlobalsTable.psVideo) {

      if(psStorageData.psThumbnailBytesList.isEmpty || psStorageData.myPsThumbnailBytesList.isEmpty) {

        final thumbnailBytes = isFromMyPs 
          ? await thumbnailGetter.getMyThumbnail(conn) 
          : await thumbnailGetter.getThumbnail(conn);

        isFromMyPs 
          ? psStorageData.setMyPsThumbnailBytes(thumbnailBytes)
          : psStorageData.setPsThumbnailBytes(thumbnailBytes);

        getByteValue.addAll(thumbnailBytes);

      } else {
        isFromMyPs 
          ? getByteValue.addAll(psStorageData.myPsThumbnailBytesList)
          : getByteValue.addAll(psStorageData.psThumbnailBytesList);

      }

    } else {

      await retrieveValue(tableNameToAssetsImage[tableName]!);

    }

    return getByteValue.toList();

  }
  
}