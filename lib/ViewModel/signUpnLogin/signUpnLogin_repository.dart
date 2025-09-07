import 'dart:convert';

import 'package:fyp/Model/signupLoginpage.dart';
import 'package:fyp/ViewModel/signUpnLogin/signUpnLogin_callApi.dart';

class signUpnLoginRepository {
  final signUpnLogin_callApi _service = signUpnLogin_callApi();

  Future<bool> signUp({
    required firstName,
    required lastName,
    required email,
    required password,
    required phoneNumber,
  }) async {
    final response = await _service.signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      // Print the server response body to see the actual error message
      print('❌ Signup failed with status: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      throw Exception('Signup failed with status: ${response.statusCode}');
    }
  }

  Future<String?> login(String email, String password) async {
    final response = await _service.login(email, password);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Login successful: ${data['user']}');
      final token = data['token']; // <-- get token here
      //print('Token received: $token');
      return token;
    } else {
      print('Login failed with status: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      return null;
    }
  }

  //  Fetch user details using email
  Future<UserInfoModule?> fetchUserDetailsByEmail(
    String email,
    String token,
  ) async {
    final response = await _service.fetchUserDetailsByEmail(email, token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //print('Fetched User Details: ${data['user']}');
      return UserInfoModule.fromJson(data['user']);
    } else {
      print('Failed to fetch user details with status: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      return null;
    }
  }

  Future<UserInfoModule?> fetchSavedUser(String email, String token) async {
    return await fetchUserDetailsByEmail(email, token);
  }
}
