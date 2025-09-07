import 'package:flutter/material.dart';
import 'editProfile_repository.dart';
import '../../Model/signupLoginpage.dart';

class EditProfileViewModel extends ChangeNotifier {
  final EditProfileRepository _repository = EditProfileRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserInfoModule? _updatedUserInfo;
  UserInfoModule? get updatedUserInfo => _updatedUserInfo;

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? phoneNumberError;

  void resetErrors() {
    firstNameError = null;
    lastNameError = null;
    emailError = null;
    phoneNumberError = null;
    _errorMessage = null;
    notifyListeners();
  }

  bool _validateInputs({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) {
    resetErrors();
    bool isValid = true;

    // First Name validation
    if (firstName.isEmpty || firstName.length < 2) {
      firstNameError = 'First name must be at least 2 characters';
      isValid = false;
    }

    // Last Name validation
    if (lastName.isEmpty || lastName.length < 2) {
      lastNameError = 'Last name must be at least 2 characters';
      isValid = false;
    }

    // Email validation
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      emailError = 'Please enter a valid email address';
      isValid = false;
    }

    // Phone Number validation
    if (phoneNumber.isEmpty ||
        !RegExp(r'^\+?[0-9]{1,4}?[0-9]{7,15}$').hasMatch(phoneNumber)) {
      phoneNumberError = 'Please enter a valid phone number';
      isValid = false;
    }

    if (!isValid) {
      notifyListeners();
    }

    return isValid;
  }

  Future<UserInfoModule?> updateProfile({
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    // Validate inputs
    if (!_validateInputs(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
    )) {
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    _updatedUserInfo = null;
    notifyListeners();

    try {
      final updatedUser = await _repository.updateUserProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      _isLoading = false;
      if (updatedUser != null) {
        _updatedUserInfo = updatedUser;
      }
      notifyListeners();

      return updatedUser;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
      return null;
    }
  }
}
