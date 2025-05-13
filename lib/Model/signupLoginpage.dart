import 'package:flutter/material.dart';
// data model for user information
import 'dart:convert'; // For Base64 decoding
import 'dart:typed_data'; // For Uint8List


class UserInfoModule {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final Uint8List? personalImage;

  UserInfoModule({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.personalImage,
  });

  factory UserInfoModule.fromJson(Map<String, dynamic> json) {
    // print('[DEBUG] Parsing UserModel from JSON: $json');
    return UserInfoModule(
      id: json['id'] ?? json['userid'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phonenumber'] ?? '',
      address: json['address'] ?? '',
      personalImage: json['personalimage'] != null
          ? base64Decode(json['personalimage']) // Decode Base64 to Uint8List
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': id,
      'name': name,
      'email': email,
      'phonenumber': phone,
      'address': address,
      'personalimage': personalImage != null
          ? base64Encode(personalImage!) // Encode Uint8List to Base64
          : null,
    };
  }
}