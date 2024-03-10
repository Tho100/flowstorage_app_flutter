import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_classes/thumbnail_getter.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/special_file.dart';
import 'package:flowstorage_fsc/interact_dialog/sharing_dialog/ask_sharing_password_dialog.dart';
import 'package:flowstorage_fsc/sharing_query/share_file_data.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_options.dart';
import 'package:flowstorage_fsc/sharing_query/verify_sharing.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProcessFileSharing {
  
  final retrieveData = RetrieveData();
  final shareFileData = ShareFileData();
  final verifySharing = VerifySharing();

  final tempData = GetIt.instance<TempDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  Future<void> _sendFileToShare({
    required String shareToName, 
    required String encryptedFileName, 
    required String shareToComment, 
    required dynamic fileData,
    required dynamic thumbnail,
  }) async {

      await shareFileData.insertValuesParams(
      sendTo: shareToName, 
      fileName: encryptedFileName, 
      comment: shareToComment,
      fileData: fileData,
      thumbnail: thumbnail,
    );

  }

  Future<Uint8List> _callFileBytesData(String selectedFilename, String tableName) async {
    
    final fileType = selectedFilename.split('.').last;

    if(Globals.imageType.contains(fileType)) {
      final indexOfImage = storageData.fileNamesFilteredList.indexOf(selectedFilename);
      return storageData.imageBytesFilteredList.elementAt(indexOfImage)!;

    } else {

      if(tempData.fileByteData.isNotEmpty) {
        return CompressorApi.compressByte(tempData.fileByteData);

      } else {
        final decompressedBytesData = await retrieveData.retrieveDataParams(userData.username, selectedFilename, tableName);
        return CompressorApi.compressByte(decompressedBytesData);

      }

    }

  }

  Future<void> _prepareFileToShare({
    required String username,
    required String fileName,
    required String? commentInput,
    required BuildContext context
  }) async {

    final fileType = fileName.split('.').last;
    
    final tableName = tempData.origin != OriginFile.home 
      ? Globals.fileTypesToTableNamesPs[fileType]! 
      : Globals.fileTypesToTableNames[fileType]!;

    final shareToComment = commentInput!.isEmpty ? '' : EncryptionClass().encrypt(commentInput);
    final encryptedFileName = EncryptionClass().encrypt(fileName);

    if (username == userData.username) {
      CustomAlertDialog.alertDialogTitle("Sharing Failed", "You can't share to yourself.");
      return;
    }

    if (await verifySharing.isOnSharingLimit()) {
      CustomAlertDialog.alertDialogTitle("Sharing Failed", "You've reached sharing limit.");
      return;
    }

    if (await verifySharing.isAlreadyUploaded(encryptedFileName, username, userData.username)) {
      CustomAlertDialog.alertDialogTitle("Sharing Failed", "You've already shared this file.");
      return;
    }    

    if (await verifySharing.unknownUser(username)) {
      CustomAlertDialog.alertDialogTitle("Sharing Failed", "User `$username` not found.");
      return;
    }

    if(await verifySharing.isDuplicatedFileName(encryptedFileName, userData.username)) {
      CustomAlertDialog.alertDialogTitle("Sharing Failed", "A file with this name already exists. Try to rename the file.");
      return;
    }

    final getReceiverDisabled = await SharingOptions.retrieveDisabled(username);

    if(getReceiverDisabled == '1') {
      CustomAlertDialog.alertDialogTitle('Sharing Failed', 'User $username disabled their file sharing.');
      return;
    }

    final getSharingAuth = await SharingOptions.retrievePassword(username);
    final passwordSharingDisabled = await SharingOptions.retrievePasswordStatus(username);

    String? thumbnailBase64;

    if(Globals.videoType.contains(fileType)) {
      thumbnailBase64 = await Future.value(
        ThumbnailGetter().getSingleThumbnail(fileName: fileName)
      );
    }

    if(passwordSharingDisabled == "0") {
      
      final fileData = await _processFileData(
        fileName: fileName, 
        tableName: tableName
      );

      if(context.mounted) {

        SharingPassword().buildAskPasswordDialog(
          sendTo: username, 
          fileName: encryptedFileName,
          comment: shareToComment,
          fileData: fileData,
          authInput: getSharingAuth,
          thumbnail: thumbnailBase64 ?? '',
          context: context,
        );

      }

      return;

    }

    await CallNotify().customNotification(
      title: "Sharing...", subMessage: "Sharing to $username"
    );
    
    final singleTextLoading = SingleTextLoading();

    if(context.mounted) {
      singleTextLoading.startLoading(
        title: "Sharing...", context: context
      );
    }

    final fileData = await _processFileData(
      fileName: fileName, 
      tableName: tableName
    );

    await _sendFileToShare(
      shareToName: username,
      encryptedFileName: encryptedFileName, 
      shareToComment: shareToComment, 
      fileData: fileData,
      thumbnail: thumbnailBase64 ?? '',
    );

    singleTextLoading.stopLoading();

    await NotificationApi.stopNotification(0);

  }

  Future<String> _processFileData({
    required String fileName, 
    required String tableName, 
  }) async {

    final fileType = fileName.split('.').last;

    final fileBytesData = await _callFileBytesData(fileName, tableName);
    final fileData = base64.encode(fileBytesData);

    return SpecialFile().ignoreEncryption(fileType) 
        ? fileData : EncryptionClass().encrypt(fileData);  

  }

  void shareOnPressed({
    required String receiverUsername,
    required String fileName,
    required String commentInput,
    required BuildContext context
  }) async {

    if (receiverUsername.isEmpty) {
      CustomAlertDialog.alertDialog("Please enter the receiver username.");
      return;
    }
    
    if (receiverUsername == userData.username) {
      CustomAlertDialog.alertDialog("You cannot share to yourself.");
      return;
    }

    await _prepareFileToShare(
      username: receiverUsername,
      fileName: fileName,
      commentInput: commentInput,
      context: context
    );
  }

}