import 'dart:convert';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class StripeCustomers {

  static Future<String> getCustomerIdByEmail(String email) async {

    const apiKey = dotenv.env['stripe_test_key'];
    const url = 'https://api.stripe.com/v1/customers';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {

      final jsonData = jsonDecode(response.body);
      final data = jsonData['data'] as List<dynamic>;

      for (final customer in data) {
        if (customer['email'] == email) {
          return customer['id'];
        }
      }

      return '';
      
    } else {
      throw Exception('Failed to retrieve customer emails');
    }

  }

  static Future<List<dynamic>> getCustomersEmails(String customEmail) async {

    const apiKey = dotenv.env['stripe_test_key'];
    const url = 'https://api.stripe.com/v1/customers';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {

      final jsonData = jsonDecode(response.body);
      final data = jsonData['data'] as List<dynamic>;
      final emails = data.map((customer) => customer['email']).toList();

      if(customEmail != "") {
        return emails.where((email) => email == customEmail).toList();
      }

      return emails;

    } else {
      throw Exception('Failed to retrieve customer emails');
    }
    
  }

  static Future<List<dynamic>> getCustomerSubscriptionsByEmail(String email) async {

    const apiKey = dotenv.env['stripe_test_key'];
    
    final url = Uri.https('api.stripe.com', '/v1/customers', {'email': email});
    final headers = {
      'Authorization': 'Bearer $apiKey',
    };

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

  static Future<void> cancelCustomerSubscriptionByEmail(String email, BuildContext context) async {

    final userData = GetIt.instance<UserDataProvider>();

    final crud = Crud();

    const apiKey = dotenv.env['stripe_test_key'];

    final subscriptions = await getCustomerSubscriptionsByEmail(email);

    if(subscriptions.isEmpty) {
      return;
    }
      
    final subscriptionId = subscriptions[0]['id'];

    final cancelUrl = Uri.https('api.stripe.com', '/v1/subscriptions/$subscriptionId');
    final headers = {
      'Authorization': 'Bearer $apiKey',
    };

    final cancelData = {
      'cancel_at_period_end': true,
    };
    
    final cancelResponse = await http.delete(cancelUrl, headers: headers, body: jsonEncode(cancelData));
    
    if(cancelResponse.statusCode != 200) {
      return;
    }
      
    await crud.execute(
      query: "UPDATE cust_type SET ACC_TYPE = :type WHERE CUST_EMAIL = :email", 
      params: {"type": "Basic", "email": userData.email});

    await crud.execute(
      query: "DELETE FROM cust_buyer WHERE CUST_USERNAME = :username", 
      params: {"username": userData.username});

    userData.setAccountType("Basic");

    await deleteEmailByEmail(userData.email);

    await LocalStorageModel().setupLocalAutoLogin(
      userData.username, userData.email, "Basic");

  }

  static Future<void> deleteEmailByEmail(String email) async {
    final customerId = await getCustomerIdByEmail(email);
    await deleteEmail(customerId);
  }

  static Future<void> deleteEmail(String customerId) async {

    const apiKey = dotenv.env['stripe_test_key'];
    final url = 'https://api.stripe.com/v1/customers/$customerId';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      Logger().i('Email deleted successfully.');
      
    } else {
      Logger().i('Failed to delete email');

    }

  }

}