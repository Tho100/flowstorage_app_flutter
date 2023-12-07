import 'package:flowstorage_fsc/data_query/crud.dart';

class VerifySharing {
  
  final crud = Crud();

  Future<bool> isAlreadyUploaded(String fileName, String receiverName, String fromName) async {

    const selectFileName = 'SELECT COUNT(*) FROM cust_sharing WHERE CUST_TO = :receiver AND CUST_FILE_PATH = :filename AND CUST_FROM = :from LIMIT 1';
    final params = {'receiver': receiverName,'filename': fileName,'from': fromName};    

    final countFileName = await crud.count(
      query: selectFileName, 
      params: params
    );

    return countFileName > 0;

  }

  Future<bool> isDuplicatedFileName(String fileName, String fromName) async {

    const selectFileName = 'SELECT COUNT(*) FROM cust_sharing WHERE CUST_FROM = :from AND CUST_FILE_PATH = :filename LIMIT 1';
    final params = {'filename': fileName,'from': fromName};    

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