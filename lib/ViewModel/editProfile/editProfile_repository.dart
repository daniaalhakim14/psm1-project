import 'dart:convert';
import '../../Model/signupLoginpage.dart';
import 'editProfile_callApi.dart';

class EditProfileRepository {
  final EditProfileCallApi _service = EditProfileCallApi();

  Future<UserInfoModule?> updateUserProfile({
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final response = await _service.updateUserProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      if (response.statusCode == 200) {
        print('✅ Profile updated successfully');
        final data = jsonDecode(response.body);
        // Assuming the API returns the updated user data
        if (data['user'] != null) {
          return UserInfoModule.fromJson(data['user']);
        }
        return null;
      } else {
        print('❌ Profile update failed with status: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      return null;
    }
  }
}
