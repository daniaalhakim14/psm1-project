import 'dart:convert';
import 'package:fyp/Model/cart.dart';
import 'package:fyp/ViewModel/cart/cart_callApi.dart';

import '../../Model/cart.dart';

class cartRepository {
  final cart_callapi _service = cart_callapi();

  Future<void> addItemCart(AddItemCart itemCartData, String token) async {
    final response = await _service.addItemCart(itemCartData.toMap(), token);
    final data = jsonDecode(response.body);
    //print('data: $data');
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode != 201) {
      throw Exception('Failed to add item cart to database: ${response.body}');
    }
  }

  Future<List<ViewItemCart>> getViewItemCart(int cartId, String token) async {
    final response = await _service.fetchViewItemCart(cartId, token);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // This is a list of maps
      //Print raw JSON response from backend
      print('Raw Expense Data from API: ${response.body}');
      final expenses = List<ViewItemCart>.from(
        data.map((x) => ViewItemCart.fromJson(x)),
      );
      /*
      for (var expense in expenses) {
        print(
          'Expense -> id: ${expense.expenseid}, amount: ${expense.expenseAmount}, category: ${expense.categoryname}, date: ${expense.expenseDate}, iconData: ${expense.iconData}, iconcolour: ${expense.iconColor}',
        );
      }
      */
      return expenses;
    } else {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load cart');
    }
  }



  Future<void> deleteItemCart(int cart_item_id, String token) async {
    final response = await _service.deleteItemCart(cart_item_id,token);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense: ${response.body}');
    }

    print('Expense deleted successfully');
  }


}