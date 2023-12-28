import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalStorageModel {

  final logger = Logger();
  final encryption = EncryptionClass();

  final _fileName = "CUST_DATAS.txt";
  final _folderName = "FlowStorageInfos";

  final _accountUsernamesFolderName = "FlowStorageAccountInfo";

  Future<List<String>> readLocalAccountUsernames() async {

    try {

      List<String> usernames = [];

      final localDir = await _retrieveLocalDirectory(
        customFolder: _accountUsernamesFolderName);

      final setupFiles = File('${localDir.path}/$_fileName');

      final fileContent = await setupFiles.readAsLines();
      
      for(final item in fileContent) {
        usernames.add(item);
      }

      return usernames;
      
    } catch(err, st) {
      logger.e('Exception from readLocalAccountUsernames {local_storage_model}', err, st); 
      return [];
    }

  }

  Future<void> setupLocalAccountUsernames(String username) async {
        
    final localDir = await _retrieveLocalDirectory(
      customFolder: _accountUsernamesFolderName);

    if (username.isNotEmpty) {
      if (!localDir.existsSync()) {
        localDir.createSync();
      }

      final setupFiles = File('${localDir.path}/$_fileName');

      try {

        setupFiles.writeAsStringSync(
          "$username\n", mode: FileMode.append);

      } catch (err, st) {
        logger.e('Exception from setupLocalAccountUsernames {local_storage_model}', err, st); 
      }

    }
    
  }

  Future<void> setupLocalAutoLogin(String custUsername, String custEmail, String accountType) async {

    final localDir = await _retrieveLocalDirectory();

    if (custUsername.isNotEmpty && custEmail.isNotEmpty) {

      if (localDir.existsSync()) {
        localDir.deleteSync(recursive: true);
      }

      localDir.createSync();

      final setupFiles = File('${localDir.path}/$_fileName');

      try {
        
        if (setupFiles.existsSync()) {
          setupFiles.deleteSync();
        }

        setupFiles.writeAsStringSync(
          "${EncryptionClass().encrypt(custUsername)}\n${EncryptionClass().encrypt(custEmail)}\n$accountType");

      } catch (err, st) {
        logger.e('Exception from setupLocalAccountUsernames {local_storage_model}', err, st); 
      }

    } 

  }

  Future<List<String>> readLocalAccountInformation() async {
    
    String username = '';
    String email = '';
    String accountType = '';

    final localDir = await _retrieveLocalDirectory();

    if (localDir.existsSync()) {
      final setupFiles = File('${localDir.path}/$_fileName');

      if (setupFiles.existsSync()) {
        final lines = await setupFiles.readAsLines();

        if (lines.length >= 2) {
          username = lines[0];
          email = lines[1];
          accountType = lines[2];
        }
      }
    }

    List<String> accountInfo = [];
    accountInfo.add(encryption.decrypt(username));
    accountInfo.add(encryption.decrypt(email));
    accountInfo.add(accountType);

    return accountInfo;

  }

  Future<void> deleteLocalAccountData() async {

    final localDir = await _retrieveLocalDirectory();

    if (localDir.existsSync()) {
      localDir.deleteSync(recursive: true);
    }

  }

  Future<Directory> _retrieveLocalDirectory({String? customFolder}) async {

    final folderName = customFolder ?? _folderName;

    final getDirApplication = await getApplicationDocumentsDirectory();
    final setupPath = '${getDirApplication.path}/$folderName';
    return Directory(setupPath);

  }

}