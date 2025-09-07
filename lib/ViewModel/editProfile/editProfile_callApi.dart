import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../configure_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileCallApi {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  Future<http.Response> updateUserProfile({
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    final String endpoint = '/user/updateProfile';
    final String url = '${AppConfig.baseUrl}$endpoint';

    // Get the current user's token
    final String? token = await _getToken();

    return await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
      }),
    );
  }
}
