import 'package:flutter/material.dart';
import 'package:fyp/Model/signupLoginpage.dart';
import 'package:fyp/ViewModel/signUpnLogin/signUpnLogin_repository.dart';

class signUpnLogin_viewmodel extends ChangeNotifier {
  final signUpnLoginRepository _repository = signUpnLoginRepository();
  bool fetchingData = false;

  UserInfoModule? _userInfo;
  UserInfoModule? get userInfo => _userInfo;

  String? _token;
  String? get authToken => _token;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? passwordError;
  String? repeatPasswordError;
  String? dobError;
  String? genderError;
  String? addressError;
  //String? cityError;
  //String? postcodeError;
  //String? stateError;
  //String? countryError;
  String? phoneNumberError;

  void resetErrors() {
    firstNameError = null;
    lastNameError = null;
    emailError = null;
    passwordError = null;
    repeatPasswordError = null;
    dobError = null;
    genderError = null;
    addressError = null;
    //cityError = null;
    //postcodeError = null;
    //stateError = null;
    //countryError = null;
    phoneNumberError = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String repeatPassword,
    required String dob,
    required String gender,
    required String address,
    //equired String city,
    //required String postcode,
    //required String state,
    //required String country,
    required String phoneNumber,
  }) async {
    resetErrors();
    if (firstName.isEmpty || firstName.length < 3) {
      firstNameError =
          'First name cannot be empty and must be at least 3 characters';
    }
    if (lastName.isEmpty || lastName.length < 3) {
      lastNameError =
          'Last name cannot be empty and must be at least 3 characters';
    }
    if (email.isEmpty ||
        !RegExp(
          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
        ).hasMatch(email)) {
      emailError = 'Enter a valid email';
    }
    if (password.isEmpty || password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }
    if (repeatPassword.isEmpty || password != repeatPassword) {
      repeatPasswordError = 'Passwords do not match';
    }
    if (dob.isEmpty) {
      dobError = 'Please enter a valid date of birth';
    }
    if (gender.isEmpty) {
      genderError = 'Please enter your gender';
    }
    if (address.isEmpty) {
      addressError = 'Address cannot be empty';
    }
    /*
    if(city.isEmpty){
      cityError = 'City canno be empty';
    }
    if(postcode.isEmpty){
      postcodeError = 'City canno be empty';
    }
    if(city.isEmpty){
      stateError = 'City canno be empty';
    }
    if(country.isEmpty){
      countryError = 'City canno be empty';
    }

     */
    if (phoneNumber.isEmpty ||
        !RegExp(r"^\+?[0-9]{1,4}?[0-9]{7,15}$").hasMatch(phoneNumber)) {
      phoneNumberError = 'Enter a valid phone number';
    }
    // If there are errors, return false
    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        passwordError != null ||
        repeatPasswordError != null ||
        dobError != null ||
        addressError != null ||
        //cityError != null ||
        //postcodeError != null ||
        //stateError != null ||
        //countryError != null||
        phoneNumberError != null) {
      notifyListeners();
      return false;
    }

    // If no errors, proceed with signup
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.signUp(
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
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    resetErrors();
    if (email.isEmpty ||
        !RegExp(
          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
        ).hasMatch(email)) {
      emailError = 'Enter a valid email';
    }
    if (password.isEmpty || password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }
    // If there are errors, return false
    if (emailError != null || passwordError != null) {
      notifyListeners();
      return false;
    }
    // If no errors, proceed with login
    _isLoading = true;
    notifyListeners();

    try {
      // call your login API/login here
      final token = await _repository.login(email, password);
      if (token != null) {
        _token = token; // - Save it here
        await fetchUserDetailsByEmail(email, token);
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint('Login failed: $e');
      debugPrint(stackTrace.toString());
      return false;
    }
  }

  // Fetch user details using email
  Future<void> fetchUserDetailsByEmail(String email, String token) async {
    try {
      _userInfo = await _repository.fetchUserDetailsByEmail(email, token);
      /*
      if (_userInfo != null) {
        print('User details fetched successfully: ${_userInfo!.toJson()}');
      } else {
        print('Failed to fetch user details');
      }
       */
      notifyListeners();
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Future<bool> autoLoginWithPrefs(String email,String token)async{
    try{
      _token = token;
      await fetchUserDetailsByEmail(email, token);
      return _userInfo != null;
    }catch (e){
      print("shared preferences failed: $e");
      return false;
    }
  }
}
