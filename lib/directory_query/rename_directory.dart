import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class RenameDirectory {

  final String oldDirectoryName;
  final String newDirectoryName;

  RenameDirectory({
    required this.oldDirectoryName,
    required this.newDirectoryName
  });

  final userData = GetIt.instance<UserDataProvider>();
  final encryption = EncryptionClass();
  final crud = Crud();

  Future<void> rename() async {

    const List<String> updateDirectoryQueries = [
      "UPDATE file_info_directory SET DIR_NAME = :newname WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username",
      "UPDATE upload_info_directory SET DIR_NAME = :newname WHERE DIR_NAME = :dirname AND CUST_USERNAME = :username"
    ];

    final params = {
      'newname': encryption.encrypt(newDirectoryName),
      'dirname': encryption.encrypt(oldDirectoryName),
      'username': userData.username,
    };

    for (final query in updateDirectoryQueries) {
      await crud.update(query: query, params: params);
    }

  }

}