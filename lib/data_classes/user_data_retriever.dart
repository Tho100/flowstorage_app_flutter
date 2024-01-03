import 'package:mysql_client/mysql_client.dart';

class UserDataRetriever {

  Future<String> retrieveAccountType({
    required MySQLConnectionPool conn,
    required String? email
  }) async {

    const retrieveCase =
        "SELECT ACC_TYPE FROM cust_type WHERE CUST_EMAIL = :email";
    final params = {'email': email};

    final retrievedData = await conn.execute(retrieveCase,params);

    return retrievedData.rows.last.assoc()['ACC_TYPE']!;

  }

  Future<String> retrieveUsername({
    required MySQLConnectionPool conn,
    required String? email
  }) async {

    const query = "SELECT CUST_USERNAME FROM information WHERE CUST_EMAIL = :email";
    final params = {'email': email};
    
    final retrievedData = await conn.execute(query,params);

    return retrievedData.rows.last.assoc()['CUST_USERNAME']!;

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

}