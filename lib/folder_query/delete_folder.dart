import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class DeleteFolder {

  final String folderName;

  DeleteFolder({required this.folderName});

  final userData = GetIt.instance<UserDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();
  
  final crud = Crud();

  Future<void> delete() async {

    const deleteFolderQuery = "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_NAME = :foldtitle";
    final params = {
      'username': userData.username, 
      'foldtitle': EncryptionClass().encrypt(folderName)
      };

    await crud.delete(
      query: deleteFolderQuery, 
      params: params
    );

    tempStorageData.folderNameList.remove(folderName);

  }
}