import 'package:flowstorage_fsc/connection/cluster_fsc.dart';

class UserDataRetriever {

  Future<String> retrieveAccountType({
    required String? email
  }) async {

    final conn = await SqlConnection.initializeConnection();

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

  Future<String> retrieveUsername({required String? email}) async {

    final conn = await SqlConnection.initializeConnection();

    const query = "SELECT CUST_USERNAME FROM information WHERE CUST_EMAIL = :email";
    final params = {'email': email};
    
    final execute = await conn.execute(query,params);

    for (final usernameRows in execute.rows) {
      return usernameRows.assoc()['CUST_USERNAME']!;
    }

    return '';
  }

  Future<List<String?>> retrieveAccountTypeAndUsername({
    required String? email
  }) async {

    final conn = await SqlConnection.initializeConnection();

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

}