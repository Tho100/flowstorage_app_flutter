import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/models/profile_picture_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalStorageModel {

  final logger = Logger();
  final encryption = EncryptionClass();

  final _fileName = "CUST_DATAS.txt";
  final _folderName = "FlowStorageInfos";

  final _accountUsernamesFolderName = "FlowStorageAccountInfo";
  final _accountPlanFolderName = "FlowStorageAccountInfoPlan";
  final _accountEmailFolderName = "FlowStorageAccountInfoEmail";

  Future<List<String>> _readLocalData(String customFolder) async {

    try {

      List<String> dataList = [];

      final localDir = await _retrieveLocalDirectory(
        customFolder: customFolder
      );

      final setupFiles = File('${localDir.path}/$_fileName');

      final fileContent = await setupFiles.readAsLines();
      
      for(final item in fileContent) {
        dataList.add(item);
      }

      return dataList;
      
    } catch(err, st) {
      logger.e('Exception from readLocalAccountUsernames {local_storage_model}', err, st); 
      return [];
    }

  }

  Future<List<String>> readLocalAccountUsernames() async {
    return await _readLocalData(_accountUsernamesFolderName);
  }

  Future<List<String>> readLocalAccountEmails() async {
    return await _readLocalData(_accountEmailFolderName);
  }

  Future<List<String>> readLocalAccountPlans() async {
    return await _readLocalData(_accountPlanFolderName);
  }

  Future<void> _setupLocalData(String customFolder, String data) async {

    final localDir = await _retrieveLocalDirectory(
      customFolder: customFolder
    );

    if (data.isNotEmpty) {
      if (!localDir.existsSync()) {
        localDir.createSync();
      }

      final setupFiles = File('${localDir.path}/$_fileName');

      try {

        setupFiles.writeAsStringSync(
          "$data\n", mode: FileMode.append);

      } catch (err, st) {
        logger.e('Exception from setupLocalAccountPlans {local_storage_model}', err, st); 
      }

    }

  }

  Future<void> setupLocalAccountUsernames(String username) async {
    await _setupLocalData(_accountUsernamesFolderName, username);
  }

  Future<void> setupLocalAccountEmails(String email) async {
    await _setupLocalData(_accountEmailFolderName, email);    
  }

  Future<void> setupLocalAccountPlans(String plan) async {
    await _setupLocalData(_accountPlanFolderName, plan);
  }

  Future<void> _deleteLocalData(String customFolder, String data) async {

    if (data.isEmpty) {
      return;
    }

    final localDir = await _retrieveLocalDirectory(
      customFolder: customFolder
    );

    final filePath = File('${localDir.path}/$_fileName');

    try {

      await filePath.delete();

    } catch (err, st) {
      logger.e('Exception from deleteLocalData {local_storage_model}', err, st);
    }

  }

  Future<void> deleteLocalAccountUsernames(String username) async {
    await _deleteLocalData(_accountUsernamesFolderName, username);
  }

  Future<void> deleteLocalAccountEmails(String email) async {
    await _deleteLocalData(_accountEmailFolderName, email);
  }

  Future<void> deleteLocalAccountPlans(String plan) async {
    await _deleteLocalData(_accountPlanFolderName, plan);
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

  Future<void> deleteAutoLoginAndOfflineFiles(String username, bool deleteLocalUsernames) async {

    final getDirApplication = await getApplicationDocumentsDirectory();

    await deleteLocalAccountData();
    
    if(deleteLocalUsernames) {
      await deleteLocalAccountEmails(username);
      await deleteLocalAccountPlans(username);
      await deleteLocalAccountUsernames(username);
    }

    final offlineDirs = Directory('${getDirApplication.path}/offline_files');
    
    if(offlineDirs.existsSync()) {
      offlineDirs.delete(recursive: true);
    }

    await ProfilePictureModel().deleteProfilePicture();

    const storage = FlutterSecureStorage();
    
    if(await storage.containsKey(key: "key0015")) {
      await storage.delete(key: "key0015");
      await storage.delete(key: "isEnabled");
    }

  }

  Future<void> updateLocalPlans(int index, String newPlan) async {

    final localDir = await _retrieveLocalDirectory(
      customFolder: _accountPlanFolderName
    );

    if (newPlan.isNotEmpty) {
      if (!localDir.existsSync()) {
        localDir.createSync();
      }

      final setupFiles = File('${localDir.path}/$_fileName');

      try {

        final content = await setupFiles.readAsString();

        final lines = content.split('\n');

        if (lines.isNotEmpty) {
          lines[index] = newPlan;
        }

        final updatedContent = lines.join('\n');

        await setupFiles.writeAsString(updatedContent);

      } catch (err, st) {
        logger.e('Exception from updateLocalPlans {local_storage_model}', err, st); 
      }

    }

  }

}