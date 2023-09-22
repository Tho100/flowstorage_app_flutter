import 'dart:convert';
import 'dart:typed_data';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class ThumbnailGetter {
  
  final userData = GetIt.instance<UserDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();
  final encryption = EncryptionClass();

  Future<List<Uint8List>> retrieveParams({required String? fileName}) async {
    
    final conn = await SqlConnection.initializeConnection();

    String query;
    Map<String, dynamic> params;
  
    if (fileName != null) {

      query = "SELECT CUST_THUMB FROM ";
      if (tempData.origin == OriginFile.home) {
        query += "file_info_vid WHERE CUST_USERNAME = :username";

      } else {
        query += "cust_sharing WHERE CUST_FROM = :username";

        if (tempData.origin == OriginFile.sharedOther) {
          query += " AND CUST_TO = :username";

        } else if (tempData.origin == OriginFile.sharedMe) {
          query += " AND CUST_FILE_PATH = :filename";
          params = {'username': userData.username, 'filename': encryption.encrypt(fileName)};

        }
      }
      params = {'username': userData.username, 'filename': encryption.encrypt(fileName)};

    } else {
      query = "SELECT CUST_THUMB FROM file_info_vid WHERE CUST_USERNAME = :username";
      params = {'username': userData.username};

    }

    final getThumbBytesQue = await conn.execute(query, params);
    final thumbnailBytesList = <Uint8List>[];

    for (final res in getThumbBytesQue.rows) {
      final thumbBytes = res.assoc()['CUST_THUMB'];
      thumbnailBytesList.add(base64.decode(thumbBytes!));
    }

    return thumbnailBytesList;
  
  }

  Future<String?> retrieveParamsSingle({
    required String? fileName,
    String? subDirName
  }) async {
    
    final conn = await SqlConnection.initializeConnection();

    String? base64EncodeThumbnail;

    final encryptedFileName = encryption.encrypt(fileName);

    if(tempData.origin == OriginFile.home) {

      const query = "SELECT CUST_THUMB FROM file_info_vid WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
      final params = {
        'username': userData.username,
        'filename': encryptedFileName
      };

      final results = await conn.execute(query,params);
      
      for(final row in results.rows) {
        base64EncodeThumbnail = row.assoc()['CUST_THUMB'];
      }

    } else if (tempData.origin == OriginFile.directory) {

      const query = "SELECT CUST_THUMB FROM upload_info_directory WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND DIR_NAME = :dirname";
      final params = {
        'username': userData.username,'filename': encryptedFileName,
        'dirname': subDirName
      };

      final results = await conn.execute(query,params);
      
      for(final row in results.rows) {
        base64EncodeThumbnail = row.assoc()['CUST_THUMB'];
      }

    } else if (tempData.origin == OriginFile.folder) {
      
      const query = "SELECT CUST_THUMB FROM folder_upload_info WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND FOLDER_TITLE = :foldname";
      final params = {
        'username': userData.username,'filename': encryptedFileName,
        'foldname': subDirName
      };

      final results = await conn.execute(query,params);
      
      for(final row in results.rows) {
        base64EncodeThumbnail = row.assoc()['CUST_THUMB'];
      }

    } else if (tempData.origin == OriginFile.sharedOther) {

      const query = "SELECT CUST_THUMB FROM cust_sharing WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
      final params = {
        'username': userData.username,
        'filename': encryptedFileName,
      };

      final results = await conn.execute(query,params);
      
      for(final row in results.rows) {
        base64EncodeThumbnail = row.assoc()['CUST_THUMB'];
      }

    } else if (tempData.origin == OriginFile.sharedMe) {

      const query = "SELECT CUST_THUMB FROM cust_sharing WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
      final params = {
        'username': userData.username,
        'filename': encryptedFileName,
      };

      final results = await conn.execute(query,params);
      
      for(final row in results.rows) {
        base64EncodeThumbnail = row.assoc()['CUST_THUMB'];
      }

    }
  
    return base64EncodeThumbnail!;

  }
}