import 'dart:convert';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class StripeCustomers extends Crud {

  final String customerEmail;

  StripeCustomers({required this.customerEmail});

  final _testApiKey = dotenv.env['stripe_test_key'];

  Future<String> getCustomerIdByEmail() async {

    const url = 'https://api.stripe.com/v1/customers';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_testApiKey',
      },
    );

    if (response.statusCode == 200) {

      final jsonData = jsonDecode(response.body);
      final data = jsonData['data'] as List<dynamic>;

      for (final customer in data) {
        if (customer['email'] == customerEmail) {
          return customer['id'];
        }
      }

      return '';
      
    } else {
      throw Exception('Failed to retrieve customer emails');
    }

  }

  Future<List<dynamic>> getCustomersEmails() async {

    const url = 'https://api.stripe.com/v1/customers';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_testApiKey',
      },
    );

    if (response.statusCode == 200) {

      final jsonData = jsonDecode(response.body);
      final data = jsonData['data'] as List<dynamic>;
      final emails = data.map((customer) => customer['email']).toList();

      if(customerEmail != "") {
        return emails.where((email) => email == customerEmail).toList();
      }

      return emails;

    } else {
      throw Exception('Failed to retrieve customer emails');
    }
    
  }

  Future<List<dynamic>> getCustomerSubscriptionsByEmail(String email) async {
    
    final url = Uri.https(
      'api.stripe.com', 
      '/v1/customers', 
      {'email': email}
    );

    final headers = {'Authorization': 'Bearer $_testApiKey'};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {

      final jsonData = jsonDecode(response.body);
      final customerData = jsonData['data'] as List<dynamic>;

      if (customerData.isNotEmpty) {

        final customer = customerData.first;
        final customerId = customer['id'];
        final subscriptionsUrl = Uri.https('api.stripe.com', '/v1/customers/$customerId/subscriptions');
        final subscriptionsResponse = await http.get(subscriptionsUrl, headers: headers);

        if(subscriptionsResponse.statusCode != 200) {
          throw Exception('Failed to fetch customer subscriptions: ${subscriptionsResponse.body}');
        }

        final subscriptionsData = jsonDecode(subscriptionsResponse.body);
        final subscriptions = subscriptionsData['data'] as List<dynamic>;

        return subscriptions;

      } else {
        throw Exception('No customer found for the given email.');
      }

    } else {
      throw Exception('Failed to retrieve customer data: ${response.body}');
    }

  }

  Future<void> cancelCustomerSubscriptionByEmail() async {

    final userData = GetIt.instance<UserDataProvider>();

    final subscriptions = await getCustomerSubscriptionsByEmail(customerEmail);

    if(subscriptions.isEmpty) {
      return;
    }
      
    final subscriptionId = subscriptions[0]['id'];

    final cancelUrl = Uri.https('api.stripe.com', '/v1/subscriptions/$subscriptionId');
    final headers = {
      'Authorization': 'Bearer $_testApiKey',
    };

    final cancelData = {
      'cancel_at_period_end': true,
    };
    
    final cancelResponse = await http.delete(cancelUrl, headers: headers, body: jsonEncode(cancelData));
    
    if(cancelResponse.statusCode != 200) {
      return;
    }
      
    await execute(
      query: "UPDATE cust_type SET ACC_TYPE = :type WHERE CUST_EMAIL = :email", 
      params: {"type": "Basic", "email": userData.email}
    );

    await execute(
      query: "DELETE FROM cust_buyer WHERE CUST_USERNAME = :username", 
      params: {"username": userData.username}
    );

    userData.setAccountType("Basic");

    await deleteEmailByEmail();

    await LocalStorageModel().setupLocalAutoLogin(
      userData.username, userData.email, "Basic"
    );

  }

  Future<void> deleteEmailByEmail() async {
    final customerId = await getCustomerIdByEmail();
    await deleteEmail(customerId);
  }

  Future<void> deleteEmail(String customerId) async {

    final url = 'https://api.stripe.com/v1/customers/$customerId';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_testApiKey',
      },
    );

    if (response.statusCode != 200) {
      Logger().i('Failed to delete email');
      return;
    } 
      
    Logger().i('Email deleted successfully.');
    
  }

}