import 'package:flutter/material.dart';
// data model for user information
import 'dart:convert'; // For Base64 decoding
import 'dart:typed_data'; // For Uint8List


class UserInfoModule {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final DateTime dob;
  final String gender;
  final String address;
  final String city;
  final String postcode;
  final String state;
  final String country;
  final String phoneNumber;
  final Uint8List? personalImage;

  UserInfoModule({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.dob,
    required this.gender,
    required this.address,
    required this.city,
    required this.postcode,
    required this.state,
    required this.country,
    required this.phoneNumber,
    required this.personalImage
  });

  factory UserInfoModule.fromJson(Map<String, dynamic> json) {
    // print('[DEBUG] Parsing UserModel from JSON: $json');
    return UserInfoModule(
      id: json['id'] ?? json['userId'] ?? 0,
      firstName: json['firstName'] ?? 'Unknown',
      lastName: json['lastName'] ?? 'Unknown',
      email: json['email'] ?? '',
      password: json['password'] ?? 'Unknown',
      dob: DateTime.tryParse(json['dob'] ?? '') ?? DateTime(1970),
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? 'unknown',
      postcode: json['postcode'],
      state: json['state'],
      country: json['country'],
      phoneNumber: json['phoneNumber'],
      personalImage: json['personalimage'] != null
          ? base64Decode(json['personalimage']) // Decode Base64 to Uint8List
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
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
      'phoneNumber': phoneNumber,
      'personalimage': personalImage != null
          ? base64Encode(personalImage!) // Encode Uint8List to Base64
          : null,
    };
  }
}