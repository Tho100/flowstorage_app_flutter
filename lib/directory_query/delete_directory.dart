import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class DeleteDirectory {

  final String? name;

  DeleteDirectory({required this.name});

  final userData = GetIt.instance<UserDataProvider>();
  final encryption = EncryptionClass();
  final crud = Crud();

  Future<void> delete() async {

    const List<String> deleteDirectoryQueries = [
      "DELETE FROM file_info_directory WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username",
      "DELETE FROM upload_info_directory WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username"
    ];

    final params = {
      'dirname': encryption.encrypt(name),
      'username': userData.username
    };

    for(final query in deleteDirectoryQueries) {
      await crud.delete(query: query, params: params);
    }

  }

}