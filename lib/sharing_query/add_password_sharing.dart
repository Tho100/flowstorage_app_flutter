import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';

class UpdatePasswordSharing {

  Future<void> update({
    required String? username, 
    required String? newAuth, 
  }) async {

    const updateSharingAuth = "UPDATE sharing_info SET SET_PASS = :getval WHERE CUST_USERNAME = :username";
    final params = {'getval': AuthModel().computeAuth(newAuth!), 'username': username!};

    const updateSharingStatus = "UPDATE sharing_info SET PASSWORD_DISABLED = 0 WHERE CUST_USERNAME = :username";
    final paramStatus = {'username': username};

    await Crud().update(
      query: updateSharingAuth, 
      params: params
    );
  
    await Crud().update(
      query: updateSharingStatus, 
      params: paramStatus
    );

  }

  Future<void> enable({required String username}) async {

    const query = "UPDATE sharing_info SET PASSWORD_DISABLED = 0 WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    await Crud().update(
      query: query, 
      params: params
    );

  }

  Future<void> disable({
    required String? username, 
  }) async {

    const query = "UPDATE sharing_info SET PASSWORD_DISABLED = 1 WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    await Crud().update(
      query: query, 
      params: params
    );

  }

}