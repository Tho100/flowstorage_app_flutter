
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/helper/random_generator.dart';
import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class RegisterUser {

  final encryption = EncryptionClass();
  final crud = Crud();

  Future<void> insertParams({
    required String? userName,
    required String? auth0, 
    required String? email,
    required String? auth1,
    required String? createdDate,
    required BuildContext context
  }) async {
    
    final conn = await SqlConnection.initializeConnection();

    final createdAccounts = await LocalStorageModel()
                                    .readLocalAccountUsernames();

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
      await insertUserInfo(userName, auth0, createdDate!, email!, auth1!);
    }

    const List<String> insertExtraInfoQuery = [
      "INSERT INTO cust_type(CUST_USERNAME, CUST_EMAIL, ACC_TYPE) VALUES (:username, :email, :type)",
      "INSERT INTO sharing_info(CUST_USERNAME, DISABLED, SET_PASS, PASSWORD_DISABLED) VALUES (:username, :disabled, :pass, :pass_disabled)"
    ];

    final params = [
      {"username": userName, "email": email, "type": "Basic"},
      {"username": userName, "disabled": "0", "pass": "DEF", "pass_disabled": "1"},
    ];

    for (int i = 0; i < insertExtraInfoQuery.length; i++) {

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

  Future<void> insertUserInfo(String? userName, String? passWord, String? createdDate, String? email, String? pin) async {

    try {
      
      final conn = await SqlConnection.initializeConnection();

      final generateRecoveryToken = Generator.generateRandomString(16) + userName!;
      final encryptedRecoveryToken = encryption.encrypt(generateRecoveryToken.replaceAll(RegExp(r'\s'), ''));

      const query = "INSERT INTO information(CUST_USERNAME, CUST_PASSWORD, CREATED_DATE, CUST_EMAIL, CUST_PIN, RECOV_TOK) VALUES (:username, :password, :date, :email, :pin, :recov_tok)";
      final params = {
        "username": userName, 
        "password": passWord, 
        "date": createdDate, 
        "email": email, 
        "pin": pin, 
        "recov_tok": encryptedRecoveryToken
      };

      await conn.execute(query, params);

      await LocalStorageModel()
        .setupLocalAutoLogin(userName, email!, "Basic");
        
      await LocalStorageModel()
        .setupLocalAccountUsernames(userName);

      await LocalStorageModel()
        .setupLocalAccountEmails(email);

      await LocalStorageModel()
        .setupLocalAccountPlans("Basic");

    } catch (err, st) {
      Logger().e(err, st);
    } 
    
  }

}