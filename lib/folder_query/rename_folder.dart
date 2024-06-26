import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class RenameFolder {
  
  final String? oldFolderTitle;
  final String? newFolderTitle;

  RenameFolder({
    required this.oldFolderTitle,
    required this.newFolderTitle
  });

  final userData = GetIt.instance<UserDataProvider>();
  final crud = Crud();

  Future<void> rename() async {

    const updateFolderNameQuery = "UPDATE folder_upload_info SET FOLDER_NAME = :newname WHERE FOLDER_NAME = :oldname AND CUST_USERNAME = :username";
    final params = {
      'username': userData.username,
      'newname': EncryptionClass().encrypt(newFolderTitle),
      'oldname': EncryptionClass().encrypt(oldFolderTitle),
    };

    await crud.execute(
      query: updateFolderNameQuery, 
      params: params
    );
    
  }
  
}