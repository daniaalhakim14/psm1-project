import 'dart:convert';

import 'package:fyp/Model/cart.dart';
import 'package:http/http.dart' as http;

import '../../configure_api.dart';

class cart_callapi{
  final http.Client _httpClient = http.Client();


  Future<http.Response> addItemCart(Map<String,dynamic> itemCartData,String token)async{
    String endpoint = '/cart/addItemToCart/${itemCartData['userid']}';
    String url = '${AppConfig.baseUrl}$endpoint';
    print(url);

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'},
      body: jsonEncode(itemCartData),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}"); // Log the response body

    return response;

  }

  Future<http.Response> fetchViewItemCart(int userid, String token) async {
    // change to Expense
    String endpoint = '/cart/getItemCart/$userid';
    String url = '${AppConfig.baseUrl}$endpoint';
    print(url);
    return await http.get(Uri.parse(url),
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'}
    );
  }

  Future<http.Response> deleteItemCart(int cart_item_id,String token) async {
    String endpoint = '/cart/deleteItemCart/$cart_item_id';
    String url = '${AppConfig.baseUrl}$endpoint';
    //print("Deleting expense with ID: $cart_item_id");

    final response = await http.delete(Uri.parse(url),
        headers: {'Content-Type': 'application/json',
          'Authorization' : 'Bearer $token'}
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    return response;
  }

}

