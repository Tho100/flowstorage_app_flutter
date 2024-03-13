import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/public_storage_query/byte_getter.dart';
import 'package:flowstorage_fsc/public_storage_query/date_getter.dart';
import 'package:flowstorage_fsc/public_storage_query/name_getter.dart';
import 'package:flowstorage_fsc/public_storage_query/title_getter.dart';
import 'package:flowstorage_fsc/public_storage_query/uploader_getter.dart';
import 'package:get_it/get_it.dart';

class PublicStorageDataRetriever {
  
  final uploaderNameGetter = UploaderGetterPs();
  final nameGetter = NameGetterPs();
  final dateGetter = DateGetterPs();
  final byteGetter = ByteGetterPs();
  final titleGetter = TitleGetterPs();

  final dataSet = <Map<String, dynamic>>[];

  final userData = GetIt.instance<UserDataProvider>();

  Future<List<Map<String, dynamic>>> getFilesInfo({
    required bool isFromMyPs
  }) async {
    
    final conn = await SqlConnection.initializeConnection();
    const tablesToCheck = GlobalsTable.tableNamesPs;

    if(isFromMyPs) {

      final futures = tablesToCheck.map((table) async {

        final fileNames = await nameGetter.getMyFileName(conn, table);
        final titles = await titleGetter.getMyTitle(conn, table);
        final bytes = await byteGetter.getMyFileData(conn, table);
        final dates = await dateGetter.getMyUploadDate(conn, table);

        final uploaderNameList = List<String>.generate(fileNames.length, (_) => userData.username);

        return {
          'uploader_name': uploaderNameList,
          'name': fileNames,
          'date': dates,
          'file_data': bytes,
          'titles': titles,
        };
      }).toList();

      final results = await Future.wait(futures);

      for (final result in results) {
        dataSet.add(result);
      }

    } else {

      final futures = tablesToCheck.map((table) async {

        final uploaderName = await uploaderNameGetter.getUploaderName(conn, table);
        final titles = await titleGetter.getTitle(conn, table);
        final fileNames = await nameGetter.getFileName(conn, table);
        final bytes = await byteGetter.getFileData(conn, table);
        final dates = await dateGetter.getUploadDate(conn, table);
    
        return {
          'uploader_name': uploaderName,
          'name': fileNames,
          'date': dates,
          'file_data': bytes,
          'titles': titles,
        };
      }).toList();

      final results = await Future.wait(futures);

      for (final result in results) {
        dataSet.add(result);
      }

    }

    return dataSet;

  }
}