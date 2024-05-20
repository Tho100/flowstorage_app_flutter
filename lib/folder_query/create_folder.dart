
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/helper/special_file.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class CreateFolder {

  final String titleFolder;
  final List<String> fileValues;
  final List<String> fileNames;
  final List<String>? videoThumbnail;

  CreateFolder({
    required this.titleFolder,
    required this.fileValues,
    required this.fileNames,
    required this.videoThumbnail
  });

  final encryption = EncryptionClass(); 
  final specialFile = SpecialFile();
  final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now()); 

  final userData = GetIt.instance<UserDataProvider>();

  Future<void> create() async {
    
    final conn = await SqlConnection.initializeConnection();

    const query = "INSERT INTO folder_upload_info VALUES (:folder_name, :username, :file_data, :upload_date, :file_name, :thumbnail)";

    final encryptedFolderName = encryption.encrypt(titleFolder);

    for (int i = 0; i < fileNames.length; i++) {

      final fileType = fileNames[i].split('.').last;

      final params = {
        'folder_name': encryptedFolderName, 
        'username': userData.username, 

        'file_data': specialFile.ignoreEncryption(fileType) 
            ? fileValues[i] 
            : encryption.encrypt(fileValues[i]),

        'file_name': encryption.encrypt(fileNames[i]),
        'upload_date': formattedDate,

        'thumbnail': videoThumbnail != null && videoThumbnail!.length > i
            ? videoThumbnail![i]
            : null
      };

      await conn.execute(query, params);
      
    }
    
  }
  
}