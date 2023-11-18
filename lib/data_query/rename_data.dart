import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class RenameData {

  final crud = Crud();
  final encryption = EncryptionClass();

  final userData = GetIt.instance<UserDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Future<void> renameFiles(String? oldFileName, String? newFileName, String? tableName,{String? username}) async {

    late final String query;
    late final Map<String,String> params;
    
    switch(tempData.origin) {
      case OriginFile.home:
        query = "UPDATE $tableName SET CUST_FILE_PATH = :newName WHERE CUST_FILE_PATH = :oldName AND CUST_USERNAME = :username";
        params = {
          'newName': encryption.encrypt(newFileName!),
          'oldName': encryption.encrypt(oldFileName!),
          'username': userData.username,
        };
      break;

      case OriginFile.sharedOther:
        query = "UPDATE cust_sharing SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_FROM = :username";
        params = {
          'username': username!,
          'newname': encryption.encrypt(newFileName),
          'oldname': encryption.encrypt(oldFileName),
        };
      break;

      case OriginFile.sharedMe:
        query = "UPDATE cust_sharing SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_TO = :username";
        params = {
          'username': username!,
          'newname': encryption.encrypt(newFileName),
          'oldname': encryption.encrypt(oldFileName),
        };
      break;

      case OriginFile.folder:
        const updateFileNameQuery = "UPDATE folder_upload_info SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_USERNAME = :username AND FOLDER_TITLE = :foldtitle";
        query = updateFileNameQuery;
        params =  {
          'username': userData.username,
          'newname': encryption.encrypt(newFileName),
          'oldname': encryption.encrypt(oldFileName),
          'foldtitle': encryption.encrypt(tempData.folderName),
        };
      break;

      case OriginFile.directory:
        query = "UPDATE upload_info_directory SET CUST_FILE_PATH = :newname WHERE CUST_FILE_PATH = :oldname AND CUST_USERNAME = :username AND DIR_NAME = :dirname";
        params =  {
          'username': userData.username,
          'newname': encryption.encrypt(newFileName),
          'oldname': encryption.encrypt(oldFileName),
          'dirname': encryption.encrypt(tempData.directoryName),
        };
      break;

      case OriginFile.offline:
        break;

      case OriginFile.public:
        break;

      case OriginFile.publicSearching:
        break;
        
    }

    await crud.update(query: query, params: params);
   
  }
}