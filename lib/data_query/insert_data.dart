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

    final defaultHomeTables = Set<String>.from(GlobalsTable.tableNames);
    final defaultPsTables = Set<String>.from(GlobalsTable.tableNamesPs);

    defaultHomeTables.remove(GlobalsTable.directoryUploadTable);
    defaultHomeTables.remove(GlobalsTable.homeVideo);
    defaultHomeTables.remove(GlobalsTable.psVideo);

    final conn = await SqlConnection.initializeConnection();

    final encryptedFilePath = encryption.encrypt(fileName);
    final encryptedFileData = encryption.encrypt(fileValue);

    final fileType = fileName.split('.').last;

    final thumbnail = videoThumbnail != null 
        ? base64.encode(videoThumbnail) 
        : null;

    final fileData = specialFile.ignoreEncryption(fileType) 
        ? fileValue 
        : encryptedFileData;

    if(defaultHomeTables.contains(tableName)) {
      await _insertFileInfo(
        conn, tableName, userName, encryptedFilePath, fileData);

    } else if (defaultPsTables.contains(tableName)) {
      await _insertFileInfoPs(
        conn, tableName, userName, encryptedFilePath, fileData);

    } else if (tableName == GlobalsTable.homeVideo) {
      await _insertVideoInfo(
        conn, tableName, userName, encryptedFilePath, fileData, thumbnail);

    } else if (tableName == GlobalsTable.psVideo) {
      await _insertVideoInfoPs(
        conn, userName, encryptedFilePath, fileData, thumbnail);

    } else if (tableName == GlobalsTable.directoryUploadTable) {
      await _insertDirectoryInfo(
        conn, tableName, userName, tempData.directoryName, fileData, encryptedFilePath, thumbnail, fileName);

    } else {
      throw ArgumentError('Invalid tableName: $tableName');

    }

  }

  Future<void> _insertFileInfo(
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

  Future<void> _insertVideoInfo(
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

  Future<void> _insertDirectoryInfo(
    MySQLConnectionPool conn,
    String tableName,
    String userName,
    String directoryName,
    String encryptedFileData,
    String encryptedFilePath,
    String? thumb,
    String fileName,
  ) async {

    final encryptedDirName = encryption.encrypt(directoryName);

    const insertFileDataQuery = 'INSERT INTO upload_info_directory (CUST_USERNAME, CUST_FILE, DIR_NAME, CUST_FILE_PATH, UPLOAD_DATE, CUST_THUMB) VALUES (?, ?, ?, ?, ?, ?)';

    await conn.prepare(insertFileDataQuery)
        ..execute([userName, encryptedFileData, encryptedDirName, encryptedFilePath, dateNow, thumb]);
  }

  Future<void> _insertFileInfoPs(
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

    tempData.addPsTotalUpload();

  }

  Future<void> _insertVideoInfoPs(
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

    tempData.addPsTotalUpload();

  }

}
