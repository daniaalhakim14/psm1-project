import 'package:flutter/material.dart';
import 'package:fyp/ViewModel/cart/cart_repository.dart';

import '../../Model/cart.dart';

class cartViewModel extends ChangeNotifier{
  final repository = cartRepository();
  final cartRepository _repository = cartRepository();
  bool fetchingData = false;

  List<ViewItemCart> _viewItemCart = [];
  List<ViewItemCart> get viewItemCart => _viewItemCart;

  Future<void> addItemCart(AddItemCart itemCartData,String token) async {
    try{
      await repository.addItemCart(itemCartData, token);
    }catch (e){
      print('Failed to add Item cart: $e');
    }
  }

  Future<void> fetchViewItemCart(int cart_item_id, String token) async {
    fetchingData = true; // Indicate that data fetching is in progress
    notifyListeners();
    try {
      _viewItemCart = await repository.getViewItemCart(cart_item_id, token);
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

  Future<void> deleteItemCart(int cart_item_id,String token) async {
    try{
      await repository.deleteItemCart(cart_item_id, token);
    }catch (e){
      print('Failed to delete item in cart: $e');
    }
  }



}