import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';

class UpdatePasswordSharing {

  final crud = Crud();

  Future<void> update({
    required String? username, 
    required String? newAuth, 
  }) async {

    const updateSharingAuth = "UPDATE sharing_info SET SET_PASS = :new_pass WHERE CUST_USERNAME = :username";
    final params = {'new_pass': AuthModel().computeAuth(newAuth!), 'username': username!};

    const updateSharingStatus = "UPDATE sharing_info SET PASSWORD_DISABLED = 0 WHERE CUST_USERNAME = :username";
    final paramStatus = {'username': username};

    await crud.execute(
      query: updateSharingAuth, 
      params: params
    );
  
    await crud.execute(
      query: updateSharingStatus, 
      params: paramStatus
    );

  }

  Future<void> enable({required String username}) async {

    const query = "UPDATE sharing_info SET PASSWORD_DISABLED = 0 WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    await crud.execute(
      query: query, 
      params: params
    );

  }

  Future<void> disable({
    required String? username, 
  }) async {

    const query = "UPDATE sharing_info SET PASSWORD_DISABLED = 1 WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    await crud.execute(
      query: query, 
      params: params
    );

  }

}