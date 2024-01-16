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

  Future<List<String>> readLocalAccountEmails() async {

    try {

      List<String> emails = [];

      final localDir = await _retrieveLocalDirectory(
        customFolder: _accountEmailFolderName);

      final setupFiles = File('${localDir.path}/$_fileName');

      final fileContent = await setupFiles.readAsLines();
      
      for(final item in fileContent) {
        emails.add(item);
      }

      return emails;
      
    } catch(err, st) {
      logger.e('Exception from readLocalAccountEmails {local_storage_model}', err, st); 
      return [];
    }

  }

  Future<List<String>> readLocalAccountPlans() async {

    try {

      List<String> plans = [];

      final localDir = await _retrieveLocalDirectory(
        customFolder: _accountPlanFolderName);

      final setupFiles = File('${localDir.path}/$_fileName');

      final fileContent = await setupFiles.readAsLines();
      
      for(final item in fileContent) {
        plans.add(item);
      }

      return plans;
      
    } catch(err, st) {
      logger.e('Exception from readLocalAccountPlans {local_storage_model}', err, st); 
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

  Future<void> setupLocalAccountEmails(String email) async {
        
    final localDir = await _retrieveLocalDirectory(
      customFolder: _accountEmailFolderName);

    if (email.isNotEmpty) {
      if (!localDir.existsSync()) {
        localDir.createSync();
      }

      final setupFiles = File('${localDir.path}/$_fileName');

      try {

        setupFiles.writeAsStringSync(
          "$email\n", mode: FileMode.append);

      } catch (err, st) {
        logger.e('Exception from setupLocalAccountEmails {local_storage_model}', err, st); 
      }

    }
    
  }

  Future<void> setupLocalAccountPlans(String plan) async {
        
    final localDir = await _retrieveLocalDirectory(
      customFolder: _accountPlanFolderName);

    if (plan.isNotEmpty) {
      if (!localDir.existsSync()) {
        localDir.createSync();
      }

      final setupFiles = File('${localDir.path}/$_fileName');

      try {

        setupFiles.writeAsStringSync(
          "$plan\n", mode: FileMode.append);

      } catch (err, st) {
        logger.e('Exception from setupLocalAccountPlans {local_storage_model}', err, st); 
      }

    }
    
  }

  Future<void> deleteLocalAccountUsernames(String username) async {
        
    final localDir = await _retrieveLocalDirectory(
      customFolder: _accountUsernamesFolderName);

    if (username.isNotEmpty) {

      final filePath = File('${localDir.path}/$_fileName');

      try {

        await filePath.delete();

      } catch (err, st) {
        logger.e('Exception from setupLocalAccountUsernames {local_storage_model}', err, st); 
      }

    }
    
  }

  Future<void> deleteLocalAccountEmails(String email) async {
        
    final localDir = await _retrieveLocalDirectory(
      customFolder: _accountEmailFolderName);

    if (email.isNotEmpty) {

      final filePath = File('${localDir.path}/$_fileName');

      try {

        await filePath.delete();

      } catch (err, st) {
        logger.e('Exception from deleteLocalAccountEmails {local_storage_model}', err, st); 
      }

    }
    
  }

  Future<void> deleteLocalAccountPlans(String plan) async {
        
    final localDir = await _retrieveLocalDirectory(
      customFolder: _accountPlanFolderName);

    if (plan.isNotEmpty) {

      final filePath = File('${localDir.path}/$_fileName');

      try {

        await filePath.delete();

      } catch (err, st) {
        logger.e('Exception from deleteLocalAccountPlans {local_storage_model}', err, st); 
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

}