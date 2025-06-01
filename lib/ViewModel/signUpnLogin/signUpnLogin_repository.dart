import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fyp/Model/signupLoginpage.dart';
import 'package:fyp/ViewModel/signUpnLogin/signUpnLogin_callApi.dart';
import 'package:http/http.dart' as http;

class signUpnLoginRepository {
  final signUpnLogin_callApi _service = signUpnLogin_callApi();

  Future<bool> signUp({
    required firstName,
    required lastName,
    required email,
    required password,
    required dob,
    required gender,
    required address,
    //required city,
    //required postcode,
    //required state,
    //required country,
    required phoneNumber,
  }) async {
    final response = await _service.signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      dob: dob,
      gender: gender,
      address: address,
      //city: city,
      //postcode: postcode,
      //state: state,
      //country: country,
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
      //print('Login successful: ${data['user']}');
      final token = data['token']; // <-- get token here
      print('✅ Token received: $token');
      return token;
    } else {
      print('Login failed with status: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      return null;
    }
  }

  //  Fetch user details using email
Future<UserInfoModule?> fetchUserDetailsByEmail(String email,String token) async{
    final response = await _service.fetchUserDetailsByEmail(email,token);
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      print('Fetched User Details: ${data['user']}');
      return UserInfoModule.fromJson(data['user']);
    }else{
      print('Failed to fetch user details with status: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      return null;
    }
}
}
