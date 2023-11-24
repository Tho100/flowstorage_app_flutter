import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class SharingName {

  final userData = GetIt.instance<UserDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Future<String> shareToOtherName() async {

    final conn = await SqlConnection.initializeConnection();

    const query = "SELECT CUST_TO FROM cust_sharing WHERE CUST_FROM = :from AND CUST_FILE_PATH = :filename";
    final params = {
      'from': userData.username,
      'filename': EncryptionClass().encrypt(tempData.selectedFileName)
    };

    final results = await conn.execute(query, params);

    for(final row in results.rows) {
      return row.assoc()['CUST_TO']!;
    }

    return ""; 
    
  }

  Future<String> sharerName() async {

    final conn = await SqlConnection.initializeConnection();
    
    const query = "SELECT CUST_FROM FROM cust_sharing WHERE CUST_TO = :from AND CUST_FILE_PATH = :filename";
    final params = {
      'from': userData.username, 
      'filename': EncryptionClass().encrypt(tempData.selectedFileName)
    };
    
    final results = await conn.execute(query, params);

    for(final row in results.rows) {
      return row.assoc()['CUST_FROM']!;
    }

    return "";
    
  }
}