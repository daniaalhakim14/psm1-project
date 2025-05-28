import 'package:flutter/material.dart';
import 'package:fyp/ViewModel/signUpnLogIn/signUpnLogin_callApi.dart';
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
    required city,
    required postcode,
    required state,
    required country,
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
      city: city,
      postcode: postcode,
      state: state,
      country: country,
      phoneNumber: phoneNumber,
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Signup failed with status: ${response.statusCode}');
    }
  }
}