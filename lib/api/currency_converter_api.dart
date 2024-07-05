import 'package:flowstorage_fsc/provider/temp_payment_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flowstorage_fsc/api/geographic_api.dart';

class CurrencyConverterApi {

  final tempData = GetIt.instance<TempPaymentProvider>();

  final countryCodeToCurrency = {
    "US": "USD",
    "DE": "EUR",
    "GB": "GBP",
    "ID": "IDR",
    "MY": "MYR",
    "BN": "BND",
    "SG": "SGD",
    "TH": "THB",
    "PH": "PHP",
    "VN": "VND",
    "CN": "CNY",
    "HK": "HKD",
    "TW": "TWD",
    "KO": "KRW",
    "BR": "BRL",
    "ME": "MXN",
    "AU": "AUD",
    "NZ": "NZD",
    "IN": "INR",
    "LK": "LKR",
    "PA": "PKR",
    "SA": "SAR",
    "AR": "AED",
    "IS": "ILS",
    "EG": "EGP",
    "TU": "TND",
    "CH": "CHF",
    "ES": "EUR",
    "SW": "SEK"
  };

  Future<String> convert({
    required double usdValue, 
    required bool isFromMyPlan
  }) async {

    String countryCode = 'US';
    String countryCurrency = 'USD';
    double conversionRate = 2.0;

    if(isFromMyPlan) {
      await _fetchConversionRate(countryCurrency);

    } else {

      if(tempData.countryCode.isEmpty && tempData.currencyConversionRate == 0.0) {

        countryCode = await GeographicApi().countryCode();
        countryCurrency = countryCodeToCurrency[countryCode]!;

        tempData.setCountryCode(countryCode);
        tempData.setCountryCurrency(countryCurrency);

        conversionRate = await _fetchConversionRate(countryCurrency);
        tempData.setCurrencyConversion(conversionRate);

      } else {
        countryCode = tempData.countryCode;
        countryCurrency = tempData.countryCurrency;
        conversionRate = tempData.currencyConversionRate;

      }

    }

    return ("$countryCurrency${usdValue*conversionRate}").toString();

  }

  Future<double> _fetchConversionRate(String currency) async {

    final apiKey = dotenv.env['currency_converter_key']!;

    final apiUrl = 'https://api.freecurrencyapi.com/v1/latest?apikey=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'][currency];
      
    } else {
      throw Exception('Failed to load exchange rates');

    }

  }

}