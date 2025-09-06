// Service class
import 'dart:convert';
import 'package:fyp/Model/expense.dart';
import 'package:http/http.dart' as http;
import '../../configure_api.dart';

class expense_callApi {
  // Indicates that the function is asynchronous and does not return a value.
  // Instead, it returns a Future, which represents a potential value or error that will be available at some point in the future.

  final http.Client _httpClient = http.Client();

  Future<http.Response> fetchCategories() async {
    String endpoint = '/category';
    String url = '${AppConfig.baseUrl}$endpoint';
    //print(url);
    return await http.get(Uri.parse(url));
  }

  Future<http.Response> addExpense(
    Map<String, dynamic> expenseData,
    String token,
  ) async {
    // change to Expense
    String endpoint = '/expense'; // Update this to match your API endpoint
    String url = '${AppConfig.baseUrl}$endpoint';

    //print("Sending transaction data: $expenseData"); // Log the data being sent

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(expenseData),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}"); // Log the response body

    return response;
  }

  Future<http.Response> fetchViewExpense(int userid, String token) async {
    // change to Expense
    String endpoint = '/expense/$userid';
    String url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> fetchListExpense(int userid, String token) async {
    String endpoint = '/expense/listExpense/$userid';
    String url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> fetchViewExpenseFinancialPlatform(
    int userid,
    String token,
  ) async {
    String endpoint = '/expense/financialPlatform/$userid'; // to change
    String url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> updateExpense(
    int expenseId,
    Map<String, dynamic> expenseData,
    String token,
  ) async {
    String endpoint = '/expense/updateExpense/$expenseId'; // your backend route
    String url = '${AppConfig.baseUrl}$endpoint';
    print('url $url');

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(expenseData),
    );

    print("Update response status: ${response.statusCode}");
    print("Update response body: ${response.body}");

    return response;
  }

  Future<http.Response> deleteExpense(
    int expenseId,
    int userid,
    String token,
  ) async {
    String endpoint = '/expense/deleteExpense/$expenseId';
    String url = '${AppConfig.baseUrl}$endpoint';
    //print("Deleting expense with ID: $expenseId");

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    return response;
  }

  // Add a dispose method to clean up
  void dispose() {
    _httpClient.close(); // Close the HTTP client to release resources
    print("HTTP client closed.");
  }
}
