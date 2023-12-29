import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';

class PublicStorageCountTotalUpload {
  
  final crud = Crud();

  Future<int> countTotalFilesUploaded() async {

    int count = 0;

    for(final tables in GlobalsTable.tableNamesPs) {
      count += await crud.countUserTableRow(tables);
    }

    return count;

  }

}