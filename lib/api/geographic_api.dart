import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeographicApi {

  Future<String> countryCode() async {
    
    final apiKey = dotenv.env['geographic_key']!;

    final response = await http.get(Uri.parse('http://apiip.net/api/check?accessKey=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['countryCode'];
      
    } else {
      throw Exception('Failed to load user country');
      
    }

  }

}