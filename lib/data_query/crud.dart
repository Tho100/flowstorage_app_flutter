import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';

class Crud {

  Future<void> execute({
    required String? query,
    required Map<String, dynamic>? params
  }) async {
    final conn = await SqlConnection.initializeConnection();
    await conn.execute(query!, params!);
  }

  Future<int> count({
    required String? query, 
    required Map<String, String>? params
  }) async {

    final conn = await SqlConnection.initializeConnection();
    final results = await conn.execute(query!, params!);

    for(final row in results.rows) {
      return row.typedColAt<int>(0)!;
    }

    return 0;
    
  }

  Future<dynamic> select({
    required String? query,
    required String? returnedColumn,
    required Map<String, String>? params
  }) async {

    final conn = await SqlConnection.initializeConnection();
    
    final results = await conn.execute(query!, params!);

    for(final row in results.rows) {
      return row.assoc()[returnedColumn]!;
    }
    
  }

  Future<int> countUserTableRow(String tableName) async {

    final conn = await SqlConnection.initializeConnection();

    final userData = GetIt.instance<UserDataProvider>();

    final countRowQuery = "SELECT COUNT(*) FROM $tableName WHERE CUST_USERNAME = :username";
    final params = {'username': userData.username};

    final results = await conn.execute(countRowQuery, params);

    for(final row in results.rows) {
      return row.typedColAt<int>(0)!;
    }

    return 0;

  }

}