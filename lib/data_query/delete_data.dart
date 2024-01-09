import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class DeleteData {

  final crud = Crud();

  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Future<void> deleteOnMultiSelection({
    required String fileName
  }) async {

    late String? query;
    late Map<String,String> params;

    final encryptedFileName = EncryptionClass().encrypt(fileName);

    switch (tempData.origin) {
      case OriginFile.home:

        storageData.homeImageBytesList.clear();
        storageData.homeThumbnailBytesList.clear();

        final fileType = fileName.split('.').last;
        final tableName = Globals.fileTypesToTableNames[fileType];

        query = "DELETE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        params = {'username': userData.username, 'filename': encryptedFileName};

        break;

      case OriginFile.directory:
        query = "DELETE FROM upload_info_directory WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND DIR_NAME = :dirname";
        params = {'username': userData.username, 'filename': encryptedFileName, 'dirname': EncryptionClass().encrypt(tempData.directoryName)};
        break;

      case OriginFile.folder:
        query = "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND FOLDER_TITLE = :foldname";
        params = {'username': userData.username, 'filename': encryptedFileName, 'foldname': EncryptionClass().encrypt(tempData.folderName)};
        break;

      case OriginFile.sharedMe:
        query = "DELETE FROM CUST_SHARING WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
        params = {'username': userData.username, 'filename': encryptedFileName};
        break;

      case OriginFile.sharedOther:
        query = "DELETE FROM cust_sharing WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
        params = {'username': userData.username, 'filename': encryptedFileName};
        break;

      case OriginFile.offline:
        query = "";
        params = {};
        OfflineMode().deleteFile(fileName);
        break;

      default:
        break;
    }

    if (query!.isNotEmpty) {
      await crud.delete(query: query, params: params);
    }

  }

  Future<void> deleteFiles({
    required String? username, 
    required String? fileName, 
    required String? tableName,
  }) async {
    
    late final String query;
    late final Map<String,String> params;

    switch (tempData.origin) {
      case OriginFile.home:
        query = "DELETE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        params = {'username': username!, 'filename': fileName!};
        break;
        
      case OriginFile.sharedMe:
        query = "DELETE FROM CUST_SHARING WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
        params = {'username': username!, 'filename': fileName!};
        break;

      case OriginFile.sharedOther:
        query = "DELETE FROM CUST_SHARING WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
        params = {'username': username!, 'filename': fileName!};
        break;

      case OriginFile.folder:
        query = "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_TITLE = :foldtitle AND CUST_FILE_PATH = :filename";
        params = {'username': username!, 'foldtitle': EncryptionClass().encrypt(tempData.folderName), 'filename': fileName!};
        break;

      case OriginFile.directory:
        query = "DELETE FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname AND CUST_FILE_PATH = :filename";
        params = {'username': username!, 'dirname': EncryptionClass().encrypt(tempData.directoryName), 'filename': fileName!};
        break;

      case OriginFile.public:
        query = "DELETE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        params = {'username': username!, 'filename': fileName!};
        break;

      default:
        break;
    }

    await crud.delete(query: query, params: params);

  }

  Future<void> deleteAccount() async {

    final params = {
      'username': userData.username
    };

    for(var tables in GlobalsTable.tableNames) {
      final query = "DELETE FROM $tables WHERE CUST_USERNAME = :username";
      await crud.delete(query: query, params: params);

    }

    for(var tables in GlobalsTable.tableNamesPs) {
      final query = "DELETE FROM $tables WHERE CUST_USERNAME = :username";
      await crud.delete(query: query, params: params);

    }

    final queries = [
      "DELETE FROM information WHERE CUST_USERNAME = :username",
      "DELETE FROM upload_info_directory WHERE CUST_USERNAME = :username",
      "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username",
      "DELETE FROM cust_sharing WHERE CUST_FROM = :username",
      "DELETE FROM cust_sharing WHERE CUST_TO = :username",
    ];

    for (final query in queries) {
      await crud.delete(query: query, params: params);
    }
    
  }

}