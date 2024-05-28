import 'dart:convert';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flutter/services.dart';
import 'package:flowstorage_fsc/data_classes/thumbnail_getter.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class FileDataGetter {

  final storageData = GetIt.instance<StorageDataProvider>();

  final crud = Crud();
  final getAssets = GetAssets();
  final thumbnailGetter = ThumbnailGetter();
  final encryption = EncryptionClass();

  final tableNameToAssetsImage = {
    GlobalsTable.homeText: "txt0.jpg",
    GlobalsTable.homePdf: "pdf0.jpg",
    GlobalsTable.homeAudio: "music0.jpg",
    GlobalsTable.homeExcel: "exl0.jpg",
    GlobalsTable.homePtx: "pptx0.jpg",
    GlobalsTable.homeWord: "doc0.jpg",
    GlobalsTable.homeExe: "exe0.jpg",
    GlobalsTable.homeMsi: "exe0.jpg",
    GlobalsTable.homeApk: "apk0.jpg"
  };

  Future<List<Uint8List>> getLeadingParams(MySQLConnectionPool conn, String username, String tableName) async {

    if (tableName == GlobalsTable.homeImage) {

      if(storageData.homeImageBytesList.isEmpty) {
        return getFileInfoParams(conn, username); 
      } 

      return storageData.homeImageBytesList;

    } 
    
    return getOtherTableParams(conn, username, tableName);

  }

  Future<List<Uint8List>> getFileInfoParams(MySQLConnectionPool conn, String username) async {

    const query = 'SELECT CUST_FILE FROM ${GlobalsTable.homeImage} WHERE CUST_USERNAME = :username';
    final params = {'username': username};

    final retrievedData = await conn.execute(query, params);

    final imageBytes = retrievedData.rows.map((row) {
      final encryptedFile = row.assoc()['CUST_FILE']!;
      final decodedFile = base64.decode(encryption.decrypt(encryptedFile));

      final buffer = ByteData.view(decodedFile.buffer);
      return Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

    }).toList();

    storageData.setHomeImageBytes(imageBytes);

    return imageBytes;

  }

  Future<List<Uint8List>> getOtherTableParams(MySQLConnectionPool conn, String username, String tableName) async {

    final getByteValue = <Uint8List>{};

    if (tableName == GlobalsTable.homeVideo) {

      if (storageData.homeThumbnailBytesList.isEmpty) {
        
        final thumbnailBytes = await thumbnailGetter.getThumbnails(conn);
        
        storageData.setHomeThumbnailBytes(thumbnailBytes);
        getByteValue.addAll(thumbnailBytes);

      } else {
        getByteValue.addAll(storageData.homeThumbnailBytesList);
        
      }

    } else if (tableName == GlobalsTable.directoryInfoTable) {

      final dirImage = await Future.wait(List.generate(1, (_) => getAssets.loadAssetsData('dir1.jpg')));
      getByteValue.addAll(dirImage);

    } else {
      await generateAssetsImage(conn, username, tableName, getByteValue, tableNameToAssetsImage[tableName]!);

    }

    return getByteValue.toList();

  }

  Future<void> generateAssetsImage(MySQLConnectionPool conn, String username, String tableName, Set<Uint8List> getByteValue, String iconName) async {

    final retrieveCountQuery = 'SELECT COUNT(*) FROM $tableName WHERE CUST_USERNAME = :username';
    final params = {'username': username};
    final countTotalRows = await crud.count(query: retrieveCountQuery, params: params);

    final loadAssetImage = await Future.wait(List.generate(countTotalRows, (_) => GetAssets().loadAssetsData(iconName)));
    getByteValue.addAll(loadAssetImage);

  }
  
}