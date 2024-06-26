import 'package:flowstorage_fsc/connection/cluster_fsc.dart';

class AuthVerification {

  Future<bool> notEqual(String getUsername, String getAuthString, String columnName) async {

    final conn = await SqlConnection.initializeConnection();

    final query = "SELECT $columnName FROM information WHERE CUST_USERNAME = :username";
    final params = {'username': getUsername};
    
    final result = await conn.execute(query, params);

    for(final row in result.rows) {
      final getAuthRows = columnName == "CUST_PASSWORD" ? row.assoc()['CUST_PASSWORD'] : row.assoc()['CUST_PIN'];
      return getAuthRows != getAuthString;
    }
    
    return true;

  }

}