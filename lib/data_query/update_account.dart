import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class UpdateAccount with Crud {

  final String selectdPlan;
  final String customerId;

  UpdateAccount({
    required this.selectdPlan, 
    required this.customerId
  });

  Future<void> updateUserAccountPlan() async {

    final userData = GetIt.instance<UserDataProvider>();

    final dateToStr = DateFormat('yyyy/MM/dd').format(DateTime.now());

    const queryUpdateAccType = 
    '''
      UPDATE cust_type 
      SET ACC_TYPE = :type 
      WHERE CUST_EMAIL = :email AND CUST_USERNAME = :username
    ''';

    final params = {
      "username": userData.username,
      "email": userData.email,
      "type": selectdPlan
    };

    await execute(query: queryUpdateAccType, params: params);

    const queryInsertBuyer = 
    '''
      INSERT INTO cust_buyer
        (CUST_USERNAME, CUST_EMAIL, ACC_TYPE, CUST_ID, PURCHASE_DATE) 
      VALUES 
        (:username, :email, :type, :id, :date)
    ''';

    final paramsBuyer = {
      "username": userData.username,
      "email": userData.email,
      "type": selectdPlan,
      "id": customerId,
      "date": dateToStr
    };

    await execute(query: queryInsertBuyer, params: paramsBuyer);

  }

}