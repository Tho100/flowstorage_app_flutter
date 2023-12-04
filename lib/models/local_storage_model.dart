import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalStorageModel {

  Future<List<String>> readLocalAccountUsernames() async {

    try {

      List<String> usernames = [];

      final getDirApplication = await getApplicationDocumentsDirectory();

      final setupPath = '${getDirApplication.path}/$localAccountUsernames';
      final setupInfosDir = Directory(setupPath);

      final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

      final fileContent = await setupFiles.readAsLines();
      
      for(var item in fileContent) {
        usernames.add(item);
      }

      return usernames;
      
    } catch(err) {
      return [];
    }

  }

  Future<void> setupLocalAccountUsernames(String username) async {
        
    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/$localAccountUsernames';
    final setupInfosDir = Directory(setupPath);

    if (username.isNotEmpty) {
      if (!setupInfosDir.existsSync()) {
        setupInfosDir.createSync();
      }

      final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

      try {

        setupFiles.writeAsStringSync(
          "$username\n", mode: FileMode.append);

      } catch (e, st) {
        Logger().e(e, st);
      }

    }
    
  }

  Future<void> setupLocalAutoLogin(String custUsername, String custEmail, String accountType) async {

    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/$localAccountInformation';
    final setupInfosDir = Directory(setupPath);
    
    if (custUsername.isNotEmpty && custEmail.isNotEmpty) {

      if (setupInfosDir.existsSync()) {
        setupInfosDir.deleteSync(recursive: true);
      }

      setupInfosDir.createSync();

      final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

      try {
        
        if (setupFiles.existsSync()) {
          setupFiles.deleteSync();
        }

        setupFiles.writeAsStringSync(
          "${EncryptionClass().encrypt(custUsername)}\n${EncryptionClass().encrypt(custEmail)}\n$accountType");

      } catch (e, st) {
        Logger().e(e, st);
      }

    } 

  }

}