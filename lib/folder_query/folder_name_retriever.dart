import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';

class FolderRetriever {

  final encryption = EncryptionClass();

  Future<List<String>> getFolderName(String? username) async {

    const query = 'SELECT FOLDER_NAME FROM folder_upload_info WHERE CUST_USERNAME = :username';
    final params = {'username': username};

    try {

      final conn = await SqlConnection.initializeConnection();

      final retrievedFolderName = await conn.execute(query, params);
      
      return retrievedFolderName.rows
        .map((row) => encryption.decrypt(row.assoc()['FOLDER_NAME']))
        .toList();

    } catch (err) {
      return <String>[];
    } 
    
  }
  
}