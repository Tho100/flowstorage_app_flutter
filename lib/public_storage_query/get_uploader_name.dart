import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:get_it/get_it.dart';

class UploaderName {

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Future<String> getUploaderName({
    required String tableName,
    required Set fileValues
  }) async {

    final conn = await SqlConnection.initializeConnection();

    final query = 'SELECT CUST_USERNAME FROM $tableName';
    final results = await conn.execute(query);

    return results.rows
      .map((row) => row.assoc()['CUST_USERNAME']!)
      .toList()[_getUsernameIndex(fileValues)];
    
  }

  int _getUsernameIndex(Set fileValues) {

    final getVideoFiles = GetIt.instance<StorageDataProvider>()
    .fileNamesList.where((file) {
      for (final fileType in fileValues) {
        if (file.endsWith('.$fileType')) {
          return true;

        }
      }
      return false;
    }).toList();

    return getVideoFiles.indexOf(tempData.selectedFileName);

  }

}