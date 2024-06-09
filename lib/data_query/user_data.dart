import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class UserData {

  final userData = GetIt.instance<UserDataProvider>();

  final crud = Crud();

  Future<void> updatePassword({
    required String newPassword,
    String? customUsername
  }) async {

    const updateAuthQuery = "UPDATE information SET CUST_PASSWORD = :new_auth WHERE CUST_USERNAME = :username"; 
    final params = {
      'new_auth': AuthModel().computeAuth(newPassword), 
      'username': customUsername ?? userData.username
    };

    await crud.execute(query: updateAuthQuery, params: params);

  }

  Future<void> deleteAccount() async {

    final params = {
      'username': userData.username
    };

    for(final tables in GlobalsTable.tableNames) {
      final query = "DELETE FROM $tables WHERE CUST_USERNAME = :username";
      await crud.execute(query: query, params: params);
    }

    for(final tables in GlobalsTable.tableNamesPs) {
      final query = "DELETE FROM $tables WHERE CUST_USERNAME = :username";
      await crud.execute(query: query, params: params);
    }

    final queries = [
      "DELETE FROM information WHERE CUST_USERNAME = :username",
      "DELETE FROM cust_type WHERE CUST_USERNAME = :username",
      "DELETE FROM sharing_info WHERE CUST_USERNAME = :username",
      "DELETE FROM upload_info_directory WHERE CUST_USERNAME = :username",
      "DELETE FROM folder_upload_info WHERE CUST_USERNAME = :username",
      "DELETE FROM cust_sharing WHERE CUST_FROM = :username",
      "DELETE FROM cust_sharing WHERE CUST_TO = :username",
      "DELETE FROM ps_report_info WHERE ISSUER_NAME = :username",
    ];

    for (final query in queries) {
      await crud.execute(query: query, params: params);
    }
    
  }

}