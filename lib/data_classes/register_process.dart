
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/helper/random_generator.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RegisterUser {

  final encryption = EncryptionClass();

  Future<void> insertParams({
    required String? userName,
    required String? auth0, 
    required String? email,
    required String? auth1,
    required String? createdDate,
    required BuildContext context
  }) async {
    
    final conn = await SqlConnection.initializeConnection();
    final crud = Crud();

    final createdAccounts = await readLocalAccountUsernames();
    final countCreatedAccounts = createdAccounts.length;

    if(countCreatedAccounts >= 2) {
      if(context.mounted) {
        Navigator.pop(context);
        CustomAlertDialog.alertDialog("You have reached the maximum number of account registration.");
      }
      return;
    }

    final verifyUsernameQue = await conn.execute(
      "SELECT CUST_USERNAME FROM information WHERE CUST_USERNAME = :username",
      {"username": userName},
    );

    if (verifyUsernameQue.rows.isNotEmpty) {
      if(context.mounted) {
        Navigator.pop(context);
        CustomAlertDialog.alertDialog("Username is taken.");
      }
      return;
    }

    final verifyEmailQue = await conn.execute(
      "SELECT CUST_EMAIL FROM information WHERE CUST_EMAIL = :email",
      {"email": email},
    );
    
    if (verifyEmailQue.rows.isNotEmpty) {
      if(context.mounted) {
        Navigator.pop(context);
        CustomAlertDialog.alertDialog("Email already exists.");
      }
      return;
    }

    if (userName!.length > 20) {
      if(context.mounted) {
        Navigator.pop(context);
        CustomAlertDialog.alertDialog("Username character length limit is 20.");
      }
      return;
    }

    if (auth0!.length <= 5) {
      if(context.mounted) {
        Navigator.pop(context);
        CustomAlertDialog.alertDialog("Password length must be greater than 5.");
      }
      return;
    }

    if(context.mounted) {
      await insertUserInfo(userName, auth0, createdDate!, email!, auth1!,context);
    }

    const List<String> insertExtraInfoQuery = [
      "INSERT INTO cust_type(CUST_USERNAME,CUST_EMAIL,ACC_TYPE) VALUES (:username,:email,:type)",
      "INSERT INTO lang_info(CUST_USERNAME,CUST_LANG) VALUES (:username,:lang)",
      "INSERT INTO sharing_info(CUST_USERNAME,DISABLED,SET_PASS,PASSWORD_DISABLED) VALUES (:username,:disabled,:pass,:pass_disabled)"
    ];

    final params = [
      {"username": userName, "email": email, "type": "Basic"},
      {"username": userName, "lang": "US"},
      {"username": userName, "disabled": "0", "pass": "DEF", "pass_disabled": "1"},
    ];

    for (var i = 0; i < insertExtraInfoQuery.length; i++) {

      final query = insertExtraInfoQuery[i];
      final param = params[i];

      await crud.insert(
        query: query,
        params: param,
      );
    }
    
    NavigatePage.permanentPageMainboard(context);

    auth0 = null;
    userName = null;
    email = null;
    auth1 = null;
  
  }

  Future<void> insertUserInfo(String? userName, String? passWord, String? createdDate, String? email, String? pin, BuildContext context) async {

    try {
      
      final conn = await SqlConnection.initializeConnection();

      final String setTokRecov = Generator.generateRandomString(16) + userName!;
      final String removeSpacesSetRecov = EncryptionClass().encrypt(setTokRecov.replaceAll(RegExp(r'\s'), ''));

      final String setTokAcc = (Generator.generateRandomString(12) + userName).toLowerCase();
      final String removeSpacesSetTokAcc = AuthModel().computeAuth(setTokAcc.replaceAll(RegExp(r'\s'), ''));

      await conn.execute(
        "INSERT INTO information(CUST_USERNAME,CUST_PASSWORD,CREATED_DATE,CUST_EMAIL,CUST_PIN,RECOV_TOK,ACCESS_TOK) "
        "VALUES (:username,:password,:date,:email,:pin,:tok,:tok_acc)",
        {"username": userName, "password": passWord, "date": createdDate, "email": email, "pin": pin, "tok": removeSpacesSetRecov,"tok_acc": removeSpacesSetTokAcc},
      );

      await setupAutoLogin(userName, email!);
      await setupAccountLocal(userName);

    } catch (dupeUsernameEx, st) {
      Logger().e(dupeUsernameEx, st);
    } 
  }

  Future<void> setupAutoLogin(String custUsername, String email) async {
    
    const accountType = "Basic";
    
    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/FlowStorageInfos';
    final setupInfosDir = Directory(setupPath);

    if (custUsername.isNotEmpty && email.isNotEmpty) {
      if (setupInfosDir.existsSync()) {
        setupInfosDir.deleteSync(recursive: true);
      }

      setupInfosDir.createSync();

      final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

      try {

        if (setupFiles.existsSync()) {
          setupFiles.deleteSync();
        }

        setupFiles.writeAsStringSync('${encryption.encrypt(custUsername)}\n${encryption.encrypt(email)}\n$accountType');

      } catch (e, st) {
        Logger().e(e, st);
      }
    }
    
  }

  Future<void> setupAccountLocal(String custUsername) async {
        
    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/FlowStorageAccountInfo';
    final setupInfosDir = Directory(setupPath);

    if (custUsername.isNotEmpty) {
      if (!setupInfosDir.existsSync()) {
        setupInfosDir.createSync();
      }

      final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

      try {

        setupFiles.writeAsStringSync(
          "$custUsername\n", mode: FileMode.append);

      } catch (e, st) {
        Logger().e(e, st);
      }
    }
    
  }

  Future<List<String>> readLocalAccountUsernames() async {

    List<String> usernames = [];

    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/FlowStorageAccountInfo';
    final setupInfosDir = Directory(setupPath);

    final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

    final fileContent = await setupFiles.readAsLines();
    
    for(var item in fileContent) {
      usernames.add(item);
    }

    return usernames;

  }

  
}