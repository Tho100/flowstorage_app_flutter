import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class CreateDirectory {

  final String? name;

  CreateDirectory({required this.name});

  final logger = Logger();
  final encryption = EncryptionClass();
  final userData = GetIt.instance<UserDataProvider>();
  
  Future<void> create() async {
    
    try {

      final conn = await SqlConnection.initializeConnection();

      const query = "INSERT INTO file_info_directory(DIR_NAME,CUST_USERNAME) VALUES (:dirname,:username)";
      final params = {'dirname': encryption.encrypt(name),'username': userData.username};

      await conn.execute(query,params);

    } catch (err, st) {
      logger.e("Exception from createDirectory {create_directory}",err, st);
    }
  }

}