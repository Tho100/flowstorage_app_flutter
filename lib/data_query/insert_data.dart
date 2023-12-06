// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/special_file.dart';
import 'package:flowstorage_fsc/provider/ps_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';
  
class InsertData {
  
  final specialFile = SpecialFile();
  final encryption = EncryptionClass();
  final dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now());

  final psUploadData = GetIt.instance<PsUploadDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Future<void> insertValueParams({
    required String tableName,
    required String fileName,
    required String userName,
    required dynamic fileValue,
    required dynamic videoThumbnail,
  }) async {

    final conn = await SqlConnection.initializeConnection();

    final encryptedFilePath = encryption.encrypt(fileName);
    final encryptedFileVal = encryption.encrypt(fileValue);

    final fileType = fileName.split('.').last;

    final thumbnail = videoThumbnail != null 
        ? base64.encode(videoThumbnail) 
        : null;

    switch (tableName) {

      case GlobalsTable.homeImage:
      case GlobalsTable.homeText:
      case GlobalsTable.homePdf:
      case GlobalsTable.homePtx:
      case GlobalsTable.homeExcel:
      case GlobalsTable.homeWord:
      case GlobalsTable.homeExe:
        await insertFileInfo(conn, tableName, userName, encryptedFilePath, encryptedFileVal);
        break;

      case GlobalsTable.homeVideo:
        await insertVideoInfo(conn, tableName, userName, encryptedFilePath, fileValue, thumbnail);
        break;

      case GlobalsTable.homeAudio:
        await insertFileInfo(conn, tableName, userName, encryptedFilePath, fileValue);
        break;

      case GlobalsTable.directoryUploadTable:
        final fileData = specialFile.ignoreEncryption(fileType) 
                          ? fileValue : encryptedFileVal;
        await insertDirectoryInfo(conn, tableName, userName, fileData, tempData.directoryName, encryptedFilePath, thumbnail, fileName);
        break;

      case GlobalsTable.psText:
      case GlobalsTable.psImage:
      case GlobalsTable.psExe:
      case GlobalsTable.psExcel:
      case GlobalsTable.psPdf:
      case GlobalsTable.psWord:
      case GlobalsTable.psApk:
        await insertFileInfoPs(conn, tableName, userName, encryptedFilePath, encryptedFileVal);
        break;

      case GlobalsTable.psVideo:
        await insertVideoInfoPs(conn, userName, encryptedFilePath, fileValue, thumbnail);
        break;

      case GlobalsTable.psAudio:
        await insertFileInfoPs(conn, tableName, userName, encryptedFilePath, fileValue);
        break;

      default:
        throw ArgumentError('Invalid tableName: $tableName');
    }
  }

  Future<void> insertFileInfo(
    MySQLConnectionPool conn,
    String tableName,
    String userName,
    String encryptedFilePath,
    String encryptedFileData,
  ) async {

    final insertFileData = 'INSERT INTO $tableName (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE) VALUES (?, ?, ?, ?)';

    await conn.prepare(insertFileData)
        ..execute([encryptedFilePath, userName, dateNow, encryptedFileData]);
  }

  Future<void> insertVideoInfo(
    MySQLConnectionPool conn,
    String tableName,
    String userName,
    String encryptedFilePath,
    String encryptedFileData,
    String? thumb,
  ) async {

    final insertVideoMetadata = 'INSERT INTO $tableName (CUST_FILE_PATH, CUST_USERNAME, CUST_FILE, UPLOAD_DATE, CUST_THUMB) VALUES (?, ?, ?, ?, ?)';

    await conn.prepare(insertVideoMetadata)
        ..execute([encryptedFilePath, userName, encryptedFileData, dateNow, thumb]);
  }

  Future<void> insertDirectoryInfo(
    MySQLConnectionPool conn,
    String tableName,
    String userName,
    String encryptedFileData,
    String directoryName,
    String encryptedFilePath,
    String? thumb,
    String fileName,
  ) async {

    final fileExtension = ".${fileName.split('.').last}";
    final encryptedDirName = encryption.encrypt(directoryName);

    const insertFileDataQuery = 'INSERT INTO upload_info_directory (CUST_USERNAME, CUST_FILE, DIR_NAME, CUST_FILE_PATH, UPLOAD_DATE, FILE_EXT, CUST_THUMB) VALUES (?, ?, ?, ?, ?, ?, ?)';

    await conn.prepare(insertFileDataQuery)
        ..execute([userName, encryptedFileData, encryptedDirName, encryptedFilePath, dateNow, fileExtension, thumb]);
  }

  Future<void> insertFileInfoPs(
    MySQLConnectionPool conn,
    String tableName,
    String userName,
    String encryptedFilePath,
    String encryptedFileData,
  ) async {

    final title = psUploadData.psTitleValue;
    final tag = psUploadData.psTagValue;

    final encryptedComment = encryption.encrypt(psUploadData.psCommentValue);

    const insertCommentQuery = 'INSERT INTO ps_info_comment (CUST_FILE_NAME, CUST_COMMENT) VALUES (?, ?)';
    final insertFileDataQuery = 'INSERT INTO $tableName (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE, CUST_TAG, CUST_TITLE) VALUES (?, ?, ?, ?, ?, ?)';

    await conn.prepare(insertCommentQuery)
        ..execute([encryptedFilePath, encryptedComment]);

    await conn.prepare(insertFileDataQuery)
        ..execute([encryptedFilePath, userName, dateNow, encryptedFileData, tag, title]);
  }

  Future<void> insertVideoInfoPs(
    MySQLConnectionPool conn,
    String userName,
    String encryptedFilePath,
    String encryptedFileData,
    String? thumb,
  ) async {

    final title = psUploadData.psTitleValue;
    final tag = psUploadData.psTagValue;

    final encryptedComment = encryption.encrypt(psUploadData.psCommentValue);

    const insertCommentQuery = 'INSERT INTO ps_info_comment (CUST_FILE_NAME, CUST_COMMENT) VALUES (?, ?)';
    const insertFileDataQuery = 'INSERT INTO ps_info_video (CUST_FILE_PATH, CUST_USERNAME, UPLOAD_DATE, CUST_FILE, CUST_THUMB, CUST_TAG, CUST_TITLE) VALUES (?, ?, ?, ?, ?, ?, ?)';

    await conn.prepare(insertCommentQuery)
        ..execute([encryptedFilePath, encryptedComment]);

    await conn.prepare(insertFileDataQuery)
        ..execute([encryptedFilePath, userName, dateNow, encryptedFileData, thumb, tag, title]);
  }

}
