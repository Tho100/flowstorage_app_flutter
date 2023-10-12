import 'dart:convert';
import 'package:http/http.dart' as http;

class GeographicsApi {

  Future<String> countryCode() async {
    
    final response = await http.get(Uri.parse('http://apiip.net/api/check?accessKey=61d755d2-ac10-4b0c-afb8-487a1f4f2cdd'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['countryCode'];
    } else {
      throw Exception('Failed to load user country');
    }

  }

}