import 'package:mysql_client/mysql_client.dart';

class UserDataRetriever {

  Future<String> retrieveAccountType({
    required MySQLConnectionPool conn,
    required String? email
  }) async {

    const retrieveCase =
        "SELECT ACC_TYPE FROM cust_type WHERE CUST_EMAIL = :email";
    final params = {'email': email};

    final results = await conn.execute(retrieveCase,params);

    String? accountType = '';
    for(final row in results.rows) {
      accountType = row.assoc()['ACC_TYPE'];
    }

    return accountType!;

  }

  Future<String> retrieveUsername({
    required MySQLConnectionPool conn,
    required String? email
  }) async {

    const query = "SELECT CUST_USERNAME FROM information WHERE CUST_EMAIL = :email";
    final params = {'email': email};
    
    final execute = await conn.execute(query,params);

    for (final usernameRows in execute.rows) {
      return usernameRows.assoc()['CUST_USERNAME']!;
    }

    return '';
  }

  Future<List<String?>> retrieveAccountTypeAndUsername({
    required MySQLConnectionPool conn,
    required String? email
  }) async {

    const retrieveCase1 =
        "SELECT CUST_USERNAME FROM information WHERE CUST_EMAIL = :email";
    const retrieveCase2 =
        "SELECT ACC_TYPE FROM cust_type WHERE CUST_EMAIL = :email";
    final params = {'email': email};


    final results = await Future.wait([
      conn.execute(retrieveCase1, params),
      conn.execute(retrieveCase2, params),
    ]);

    return results
        .expand((result) => result.rows.map((row) => row.assoc().values.first))
        .toList();
  }

  Future<Map<String, String>> retrieveAccountAuthentication({
    required MySQLConnectionPool conn,
    required String username
  }) async {

    Map<String, String> values = {};

    const query = "SELECT CUST_PASSWORD, CUST_PIN FROM information WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    final results = await conn.execute(query, params);

    for (final rows in results.rows) {
      final password = rows.assoc()['CUST_PASSWORD']!;
      final pin = rows.assoc()['CUST_PIN']!;
      values['password'] = password;
      values['pin'] = pin;
    }

    return values;
  }

}