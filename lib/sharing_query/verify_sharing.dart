import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:get_it/get_it.dart';

class VerifySharing {
  
  final crud = Crud();

  final userData = GetIt.instance<UserDataProvider>();

  Future<bool> isOnSharingLimit() async {

    const selectTotalShare = 'SELECT COUNT(*) FROM cust_sharing WHERE CUST_FROM = :username';
    final params = {
      'username': userData.username, 
    };    

    final countTotalShare = await crud.count(
      query: selectTotalShare, 
      params: params
    );

    final uploadLimit = AccountPlan.mapFilesUpload[userData.accountType]!;

    return countTotalShare >= uploadLimit;

  }

  Future<bool> isAlreadyUploaded(String fileName, String receiverName, String fromName) async {

    const selectFileName = 'SELECT COUNT(*) FROM cust_sharing WHERE CUST_TO = :receiver AND CUST_FILE_PATH = :filename AND CUST_FROM = :from LIMIT 1';
    final params = {
      'receiver': receiverName, 
      'filename': fileName, 
      'from': fromName
    };    

    final countFileName = await crud.count(
      query: selectFileName, 
      params: params
    );

    return countFileName > 0;

  }

  Future<bool> isDuplicatedFileName(String fileName, String fromName) async {

    const selectFileName = 'SELECT COUNT(*) FROM cust_sharing WHERE CUST_FROM = :from AND CUST_FILE_PATH = :filename LIMIT 1';
    final params = {'filename': fileName, 'from': fromName};    

    final countFileName = await crud.count(
      query: selectFileName, 
      params: params
    );

    return countFileName > 0;

  }

  Future<bool> unknownUser(String receiverName) async {

    const query = 'SELECT COUNT(*) FROM information WHERE CUST_USERNAME = :username';
    final params = {'username': receiverName};

    final countReceiverName = await crud.count(
      query: query, 
      params: params
    );

    return countReceiverName == 0;

  }

}