import 'package:flutter/material.dart';
import 'package:fyp/ViewModel/cart/cart_repository.dart';

import '../../Model/cart.dart';

class cartViewModel extends ChangeNotifier{
  final repository = cartRepository();
  final cartRepository _repository = cartRepository();
  bool fetchingData = false;

  List<ViewItemCart> _viewItemCart = [];
  List<ViewItemCart> get viewItemCart => _viewItemCart;
  List<CompareCart> _compareCart = [];
  List<CompareCart> get compareCart => _compareCart;

  Future<void> addItemCart(AddItemCart itemCartData,String token) async {
    try{
      await repository.addItemCart(itemCartData, token);
    }catch (e){
      print('Failed to add Item cart: $e');
    }
  }

  Future<void> fetchViewItemCart(int userid, String token) async {
    fetchingData = true; // Indicate that data fetching is in progress
    notifyListeners();
    try {
      _viewItemCart = await repository.getViewItemCart(userid, token);
      // ✅ Print each expense (or just selected fields)
      /*
      for (var itemCart in _viewItemCart) {
        print('📌 ExpenseID: ${itemCart.cartId}, Name: ${expense.expenseName}, Amount: ${expense.expenseAmount}, Date: ${expense.expenseDate}');
      }

       */
    } catch (e) {
      print('Failed to load item cart : $e');
      _viewItemCart = [];
    } finally {
      fetchingData = false; // Data fetching completed
      notifyListeners();
    }
  }

  Future<void> updateItemCartQty(UpdateItemCartQty updateCartQty, String token) async{
    try{
      await repository.updateItemCartQty(updateCartQty, token);
    } catch(e){
      print('Failed to update item cart quantity: $e');
    }
  }

  Future<void> removeItemInCart(RemoveItemInCart removeItemInCart, String token) async{
    try{
      await repository.removeItemInCart(removeItemInCart, token);
    } catch(e){
      print('Failed to update item cart quantity: $e');
    }
  }

  Future<void> deleteCart(int userid,String token) async {
    try{
      await repository.deleteItemFromCart(userid, token);
    }catch (e){
      print('Failed to delete item in cart: $e');
    }
  }

  Future<void> fetchCompareCart(Map<String, dynamic> compareCartPayload, String token) async {
    fetchingData = true; // Indicate that data fetching is in progress
    notifyListeners();
    try {
      _compareCart = await repository.getCompareCart(compareCartPayload, token);
      // ✅ Print each expense (or just selected fields)
      /*
      for (var itemCart in _viewItemCart) {
        print('📌 ExpenseID: ${itemCart.cartId}, Name: ${expense.expenseName}, Amount: ${expense.expenseAmount}, Date: ${expense.expenseDate}');
      }

       */
    } catch (e) {
      print('Failed to load compare cart : $e');
      _compareCart = [];
    } finally {
      fetchingData = false; // Data fetching completed
      notifyListeners();
    }
  }

  /*
  List<StoreComparison> _compareCartResults = [];
  List<StoreComparison> get compareCartResults => _compareCartResults;

  Future<void> fetchCompareCartResults(Map<String, dynamic> cartPayload, String token) async {
    fetchingData = true;
    notifyListeners();

    try {
      _compareCartResults = await repository.getCompareCartResults(cartPayload, token);
    } catch (e) {
      print("Error fetching compare cart results: $e");
      _compareCartResults = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }
   */

}