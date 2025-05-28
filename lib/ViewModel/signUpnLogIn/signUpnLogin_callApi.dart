
import 'dart:convert';
import 'package:fyp/configure_api.dart' show AppConfig;
import 'package:http/http.dart' as http;

class signUpnLogin_callApi{

  Future<http.Response> logIn(String email, String password) async {
    const String endpoint = '/user/login';
    print( '${AppConfig.baseUrl}$endpoint');
    final String url = '${AppConfig.baseUrl}$endpoint';
    return await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  // Fetch user details by email
  Future<http.Response> fetchUserDetailsByEmail(String email) async {
    final String endpoint = '/user/email/$email'; // Endpoint for fetching user details by email
    final String url = '${AppConfig.baseUrl}$endpoint';

    return await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
  }

  // for user register new account
  Future<http.Response> signUp({
    required firstName,
    required lastName,
    required email,
    required password,
    required dob,
    required gender,
    required address,
    required city,
    required postcode,
    required state,
    required country,
    required phoneNumber,
  }) async {

    final String endpoint = '/user/signUp';
    final String url = '${AppConfig.baseUrl}$endpoint';

    return await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'dob': dob,
        'gender': gender,
        'address': address,
        'city': city,
        'postcode': postcode,
        'state': state,
        'country': country,
        'phoneNumber':phoneNumber,
      }),
    );
  }

}


