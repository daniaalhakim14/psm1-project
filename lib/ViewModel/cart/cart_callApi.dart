import 'dart:convert';

import 'package:fyp/Model/cart.dart';
import 'package:http/http.dart' as http;

import '../../configure_api.dart';

class cart_callapi {
  final http.Client _httpClient = http.Client();

  Future<http.Response> addItemCart(Map<String, dynamic> itemCartData, String token,) async {
    String endpoint = '/cart/addItemToCart/${itemCartData['userid']}';
    String url = '${AppConfig.baseUrl}$endpoint';
    print(url);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(itemCartData),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}"); // Log the response body

    return response;
  }

  Future<http.Response> fetchViewItemCart(int userid, String token) async {
    String endpoint = '/cart/getItemCart/$userid';
    String url = '${AppConfig.baseUrl}$endpoint';
    print(url);
    return await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> updateItemCartQty(Map<String, dynamic> updateCartQty, String token,) async {
    String endpoint = '/cart/updateItemCartQty/${updateCartQty['userid']}';
    String url = '${AppConfig.baseUrl}$endpoint';
    print("updating expense with ID: ${updateCartQty['userid']}");
    print('${url}');
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updateCartQty),
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}"); // Log the response body
    return response;
  }

  Future<http.Response> removeItemInCart(Map<String, dynamic> removeItemInCart, String token,) async {
    String endpoint = '/cart/removeItemInCart/${removeItemInCart['userid']}';
    String url = '${AppConfig.baseUrl}$endpoint';
    print("updating expense with ID: ${removeItemInCart['userid']}");
    print('${url}');
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(removeItemInCart),
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}"); // Log the response body
    return response;
  }

  Future<http.Response> deleteItemFromCart(int userid, String token) async {
    String endpoint = '/cart/deleteItemFromCart/$userid';
    String url = '${AppConfig.baseUrl}$endpoint';
    print("Deleting expense with ID: $userid");
    print('${url}');

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

  Future<http.Response> fetchCompareCart( Map<String,dynamic> compareCartPayload, String token)async{
    String endpoint ='/cart/compareCart/${compareCartPayload['userid']}';
    String url = '${AppConfig.baseUrl}$endpoint';
    print(url);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(compareCartPayload),
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}"); // Log the response body
    return response;
  }


}
