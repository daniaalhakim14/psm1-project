import 'dart:convert';
import 'package:fyp/Model/cart.dart';
import 'package:fyp/ViewModel/cart/cart_callApi.dart';

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

  Future<List<ViewItemCart>> getViewItemCart(int userid, String token) async {
    final response = await _service.fetchViewItemCart(userid, token);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // This is a list of maps
      //Print raw JSON response from backend
      //print('Raw Expense Data from API: ${response.body}');
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

  Future<void> updateItemCartQty(UpdateItemCartQty updateCartQty, String token) async{
    final response = await _service.updateItemCartQty(updateCartQty.toMap(), token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Response status: ${response.statusCode}");
      print("Response body: $data");
      return data;
    }else {
      throw Exception('Failed to update item cart quantity: ${response.body}');
    }
  }
  Future<void> removeItemInCart(RemoveItemInCart removeItemInCart, String token) async{
    final response = await _service.removeItemInCart(removeItemInCart.toMap(), token);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Response status: ${response.statusCode}");
      print("Response body: ${data}");
      return data;
    }else {
      throw Exception('Failed to update item cart quantity: ${response.body}');
    }
  }

  Future<void> deleteItemFromCart(int userid, String token) async {
    final response = await _service.deleteItemFromCart(userid,token);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense: ${response.body}');
    }
    print('Expense deleted successfully');
  }

  Future<List<CompareCart>> getCompareCart(Map<String,dynamic> compareCartPayload, String token) async {
    final response = await _service.fetchCompareCart(compareCartPayload, token);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // This is a list of maps
      //Print raw JSON response from backend
      //print('Raw Expense Data from API: ${response.body}');
      final compareCart = List<CompareCart>.from(
        data.map((x) => CompareCart.fromJson(x)),
      );
      /*
      for (var expense in expenses) {
        print(
          'Expense -> id: ${expense.expenseid}, amount: ${expense.expenseAmount}, category: ${expense.categoryname}, date: ${expense.expenseDate}, iconData: ${expense.iconData}, iconcolour: ${expense.iconColor}',
        );
      }
      */
      return compareCart;
    } else {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load cart');
    }
  }

  /*
  Future<List<StoreComparison>> getCompareCartResults(Map<String, dynamic> compareCartPayload, String token) async {
    final response = await _service.fetchCompareCart(compareCartPayload, token);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => StoreComparison.fromJson(json)).toList();
    } else {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load compare cart results');
    }
  }
   */

}