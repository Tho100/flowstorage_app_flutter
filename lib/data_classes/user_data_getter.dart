import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:mysql_client/mysql_client.dart';

class UserDataGetter {

  Future<String> getAccountType({
    required MySQLConnectionPool conn,
    required String? email
  }) async {

    const query = "SELECT ACC_TYPE FROM cust_type WHERE CUST_EMAIL = :email";
    final params = {'email': email};

    final retrievedData = await conn.execute(query, params);

    return retrievedData.rows.last.assoc()['ACC_TYPE']!;

  }

  Future<String> getUsername({
    required MySQLConnectionPool conn,
    required String? email
  }) async {

    const query = "SELECT CUST_USERNAME FROM information WHERE CUST_EMAIL = :email";
    final params = {'email': email};
    
    final retrievedData = await conn.execute(query,params);

    return retrievedData.rows.last.assoc()['CUST_USERNAME']!;

  }

  Future<List<String?>> getAccountTypeAndUsername({
    required MySQLConnectionPool conn,
    required String? email
  }) async {

    const getUsernameQuery =
      "SELECT CUST_USERNAME FROM information WHERE CUST_EMAIL = :email";

    const getAccountPlanQuery =
      "SELECT ACC_TYPE FROM cust_type WHERE CUST_EMAIL = :email";

    final params = {'email': email};

    final results = await Future.wait([
      conn.execute(getUsernameQuery, params),
      conn.execute(getAccountPlanQuery, params),
    ]);

    return results
        .expand((result) => result.rows.map((row) => row.assoc().values.first))
        .toList();

  }

  Future<Map<String, String>> getAccountAuthentication({
    required MySQLConnectionPool conn,
    required String username
  }) async {

    const query = "SELECT CUST_PASSWORD, CUST_PIN FROM information WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    final results = await conn.execute(query, params);

    final lastRow = results.rows.last;
    final values = {
      'password': lastRow.assoc()['CUST_PASSWORD']!,
      'pin': lastRow.assoc()['CUST_PIN']!,
    };

    return values;

  }

  Future<String> getRecoveryToken(String username) async {

    const getRecoveryToken = "SELECT RECOV_TOK FROM information WHERE CUST_USERNAME = :username";
    final params = {'username': username};    

    final returnAuth = await Crud().select(
      query: getRecoveryToken, 
      returnedColumn: "RECOV_TOK", 
      params: params
    );

    return EncryptionClass().decrypt(returnAuth);

  }

}