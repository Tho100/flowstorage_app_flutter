import 'dart:typed_data';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/data_classes/user_data_retriever.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/just_loading.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/folder_query/folder_name_retriever.dart';

class SignInUser {

  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final encryption = EncryptionClass();
  final userDataRetriever = UserDataRetriever();
  
  final crud = Crud();
  final logger = Logger();

  String custEmailInit = '';

  Future<void> _callFileData(MySQLConnectionPool conn, bool isChecked, BuildContext context) async {

    final custUsernameList = await userDataRetriever.retrieveAccountTypeAndUsername(email: custEmailInit);
    final custUsernameGetter = custUsernameList[0]!;
    final custTypeGetter = custUsernameList[1]!;

    tempData.setOrigin(OriginFile.home);
    userData.setUsername(custUsernameGetter);
    userData.setEmail(custEmailInit);
    userData.setAccountType(custTypeGetter);

    final futures = await DataCaller().startupDataCaller(
      conn: conn, username: custUsernameGetter);
  
    final results = await Future.wait(futures);

    final fileNames = <String>{};
    final bytes = <Uint8List>[];
    final dates = <String>[];
    final retrieveFolders = <String>{};

    for (final result in results) {
      final fileNamesForTable = result[0] as List<String>;
      final bytesForTable = result[1] as List<Uint8List>;
      final datesForTable = result[2] as List<String>;

      fileNames.addAll(fileNamesForTable);
      bytes.addAll(bytesForTable);
      dates.addAll(datesForTable);
    }

    final uniqueFileNames = fileNames.toList();
    final uniqueBytes = bytes.toList();

    if (await crud.countUserTableRow(GlobalsTable.folderUploadTable) > 0) {
      retrieveFolders.addAll(await FolderRetriever().retrieveParams(custUsernameGetter));
    }

    final uniqueFolder = retrieveFolders.toList();

    storageData.setFilesName(uniqueFileNames);
    storageData.setImageBytes(uniqueBytes);
    storageData.setFilesDate(dates);
    
    tempStorageData.setFoldersName(uniqueFolder);

    if (isChecked) {
      await LocalStorageModel()
        .setupLocalAutoLogin(custUsernameGetter,custEmailInit,custTypeGetter);
    }

    custUsernameList.clear();

  }

  Future<void> logParams(
    String? email, String? auth0, String? auth1, bool isChecked, BuildContext context) async {

    final conn = await SqlConnection.initializeConnection();

    try {

      final custUsername = await userDataRetriever.retrieveUsername(email: email);

      if (custUsername.isNotEmpty) {

        final localUsernames = await LocalStorageModel().readLocalAccountUsernames();

        if(localUsernames.isEmpty && isChecked) {
          await LocalStorageModel().setupLocalAccountUsernames(custUsername);
        }

        custEmailInit = email!;

        final custPasOriginal = await getCustPassword(custUsername, conn);
        final custPinOriginal = await getCustPin(custUsername, conn);

        final case0 = AuthModel().computeAuth(auth0!) == custPasOriginal;
        final case1 = AuthModel().computeAuth(auth1!) == custPinOriginal;

        if (case0 && case1) {
          
          final justLoading = JustLoading();

          if(context.mounted) {
            justLoading.startLoading(context: context);
          }

          await _callFileData(conn, isChecked, context);

          justLoading.stopLoading();
          
          if(context.mounted) {
            NavigatePage.permanentPageMainboard(context);
          }

        } else {
          
          if(context.mounted) {
            CustomAlertDialog.alertDialog("Password or PIN Key is incorrect.");
          }

        }
      } else {

        if(context.mounted) {
          CustomAlertDialog.alertDialog("Account not found.");
        }

      }

    } catch (err, st) {

      if(context.mounted) {
        CustomAlertDialog.alertDialogTitle("Something is wrong...", "No internet connection.");
      }

      logger.e("Exception from logParams {MYSQL_login}", err, st);
      
    } finally {
      await conn.close();
    }
  }

  Future<String> getCustPassword(String custUsername, conn) async {
    var getPassword = await conn.execute(
        "SELECT CUST_PASSWORD FROM information WHERE CUST_USERNAME = :username",
        {"username": custUsername});

    for (var passIterates in getPassword.rows) {
      return passIterates.assoc()['CUST_PASSWORD']!;
    }

    return '';
  }

  Future<String> getCustPin(String custUsername, conn) async {
    var getPin = await conn.execute(
        "SELECT CUST_PIN FROM information WHERE CUST_USERNAME = :username",
        {"username": custUsername});

    for (var pinIterates in getPin.rows) {
      return pinIterates.assoc()['CUST_PIN']!;
    }

    return '';
  }
}