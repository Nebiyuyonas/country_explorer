import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/country.dart';
import 'api_exception.dart';

class CountryApiService {
  static const String _baseUrl = 'restcountries.com';
  static const Duration _timeout = Duration(seconds: 10);

  // Fields to request — keeps the response small
  static const String _fields =
      'name,flag,region,subregion,capital,population,area,currencies,languages,timezones';

  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<Country>> fetchAllCountries() async {
    try {
      final uri = Uri.https(_baseUrl, '/v3.1/all', {'fields': _fields});
      final response = await http.get(uri).timeout(_timeout);
      _checkResponse(response);

      final List<dynamic> data = jsonDecode(response.body);
      final countries = data
          .map((json) => Country.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort alphabetically by name
      countries.sort((a, b) => a.name.compareTo(b.name));
      return countries;
    } on SocketException {
      throw const ApiException(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on FormatException {
      throw const ApiException('Received unexpected data from the server.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<List<Country>> searchCountries(String query) async {
    if (query.trim().isEmpty) return fetchAllCountries();

    try {
      final uri = Uri.https(
        _baseUrl,
        '/v3.1/name/${Uri.encodeComponent(query.trim())}',
        {'fields': _fields},
      );
      final response = await http.get(uri).timeout(_timeout);

      // 404 means no results found — return empty list
      if (response.statusCode == 404) return [];

      _checkResponse(response);

      final List<dynamic> data = jsonDecode(response.body);
      final countries = data
          .map((json) => Country.fromJson(json as Map<String, dynamic>))
          .toList();

      countries.sort((a, b) => a.name.compareTo(b.name));
      return countries;
    } on SocketException {
      throw const ApiException(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on FormatException {
      throw const ApiException('Received unexpected data from the server.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }
}
