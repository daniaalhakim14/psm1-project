// data model for user information
import 'dart:convert'; // For Base64 decoding
import 'dart:typed_data'; // For Uint8List

class UserInfoModule {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  //final String password;
  final String phoneNumber;
  final Uint8List? personalImage;
  final String? usertype;

  UserInfoModule({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    //required this.password,
    required this.phoneNumber,
    required this.personalImage,
    required this.usertype,
  });

  factory UserInfoModule.fromJson(Map<String, dynamic> json) {
    return UserInfoModule(
      id: int.tryParse(json['userid'].toString()) ?? 0,
      firstName: json['first_name'] ?? 'Unknown',
      lastName: json['last_name'] ?? 'Unknown',
      email: json['email'] ?? '',
      //password: json['password'] ?? 'Unknown',
      phoneNumber: json['phonenumber'] ?? '',
      personalImage:
          json['image'] != null
              ? base64Decode(json['image']) // Decode Base64 to Uint8List
              : null,
      usertype: json['usertype'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      //'password': password,
      'phonenumber': phoneNumber,
      'image':
          personalImage != null
              ? base64Encode(personalImage!) // Encode Uint8List to Base64
              : null,
      'usertype': usertype,
    };
  }
}
