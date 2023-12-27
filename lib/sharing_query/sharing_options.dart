import 'package:flowstorage_fsc/Connection/cluster_fsc.dart';

class SharingOptions {

  static Future<void> disableSharing(String username) async {

    final conn = await SqlConnection.initializeConnection();

    const query = "UPDATE sharing_info SET DISABLED = 1 WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    await conn.execute(query,params);
    
  } 

  static Future<void> enableSharing(String username) async {

    final conn = await SqlConnection.initializeConnection();

    const query = "UPDATE sharing_info SET DISABLED = 0 WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    await conn.execute(query,params);
    
  } 

  static Future<String> retrieveDisabled(String username) async {

    final conn = await SqlConnection.initializeConnection();

    const query = "SELECT DISABLED FROM sharing_info WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    final results = await conn.execute(query,params);
    
    String? disabledStatus = "";

    for(final row in results.rows) {
      return row.assoc()['DISABLED']!;
    }

    return disabledStatus;
    
  } 

  static Future<String> retrievePassword(String username) async {

    final conn = await SqlConnection.initializeConnection();

    const query = "SELECT SET_PASS FROM sharing_info WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    final results = await conn.execute(query,params);
    
    String? sharingAuth = "";
    for(final row in results.rows) {
      sharingAuth = row.assoc()['SET_PASS'];
    }

    return sharingAuth!;
    
  } 

  static Future<String> retrievePasswordStatus(String username) async {

    final conn = await SqlConnection.initializeConnection();

    const query = "SELECT PASSWORD_DISABLED FROM sharing_info WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    final results = await conn.execute(query,params);
    
    String? sharingAuth = "";
    for(final row in results.rows) {
      sharingAuth = row.assoc()['PASSWORD_DISABLED'];
    }

    return sharingAuth!;
    
  } 

}