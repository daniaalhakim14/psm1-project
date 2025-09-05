// A bridge between view layer and repository (data layer)

import 'package:flutter/material.dart';
import '../../Model/Category.dart';
import '../../Model/expense.dart';
import 'expense_repository.dart';

// ChangeNotifier allows View Model to notify listeners when data changes
class expenseViewModel extends ChangeNotifier{

  final repository = expenseCategoryRepository();
  final expenseCategoryRepository _repository = expenseCategoryRepository();

  bool fetchingData = false;
  List<ExpenseCategories> _categoryList = [];
  List<ExpenseCategories> get categoryList => _categoryList;
  List<ViewExpense> _ViewExpense = [];
  List<ViewExpense> get viewExpense => _ViewExpense;
  List<ListExpense> _listExpense = [];
  List<ListExpense> get listExpense => _listExpense;
  List<ViewExpenseFinancialPlatform> _viewExpenseFinancialPlatform = [];
  List<ViewExpenseFinancialPlatform> get viewExpenseFinancialPlatform => _viewExpenseFinancialPlatform;

  Future<void> fetchCategories() async {
    fetchingData = true;
    notifyListeners();
    try {
      _categoryList = await repository.getCategories();
      //print('Loaded Categories: $_category');
    } catch (e) {
      print('Failed to load Basic Category: $e');
      _categoryList = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

// expense_viewmodel.dart
  Future<bool> addExpense(AddExpense expense, String token) async {
    try {
      final ok = await repository.addExpense(expense, token);
      if (ok) {
        notifyListeners(); // if you have observable state that changed
        return true;
      }
      return false;
    } catch (e) {
      // Safety net if repository ever throws
      print('Failed to add new expense: $e');
      return false; // 👈 important
    }
  }


  Future<void> fetchViewExpense(int userid, String token) async {
    fetchingData = true; // Indicate that data fetching is in progress
    notifyListeners();
    try {
      _ViewExpense = await repository.getViewExpense(userid,token);
      // ✅ Print each expense (or just selected fields)
      /*
      for (var expense in _ViewExpense) {
        print('📌 ExpenseID: ${expense.expenseid}, Name: ${expense.expenseName}, Amount: ${expense.expenseAmount}, Date: ${expense.expenseDate},iconcolor: ${expense.iconColor}');
      }
       */
    } catch (e) {
      print('Failed to load transaction expenses: $e');
      _ViewExpense = [];
    } finally {
      fetchingData = false; // Data fetching completed
      notifyListeners();
    }
  }

  Future<void> fetchListExpense(int userid, String token) async{
    fetchingData = true;
    notifyListeners();
    try{
      /*
      for (var expense in _listExpense) {
        print('📌 ExpenseID: ${expense.expenseid}, Name: ${expense.expenseName}, Amount: ${expense.expenseAmount}, Date: ${expense.expenseDate}');
      }
       */

      _listExpense = await repository.getListExpense(userid, token);
    }catch(e){
      print('Failed to load list expense: $e');
      _listExpense = [];
    } finally{
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchViewExpenseFinancialPlatform(int userid, String token) async{
    try {
      _viewExpenseFinancialPlatform = await repository.getViewExpenseFinancialPlatform(userid, token);
      // ✅ Print each expense (or just selected fields)
      /*
      for (var expense in _viewExpenseFinancialPlatform) {
        print('📌 ExpenseID: ${expense.expenseid}, PlatformId:${expense.platformid} Name: ${expense.name}, Amount: ${expense.expenseAmount}, Date: ${expense.expenseDate}, IconColour: ${expense.iconColor}');
      }

       */
    } catch (e) {
      print('Failed to load financial platform Expense: $e');
      _ViewExpense = [];
    } finally {
      fetchingData = false; // Data fetching completed
      notifyListeners();
    }
  }

  Future<void> updateExpense(UpdateExpense updateexpense, String token) async{
    try{
      await repository.updateExpense(updateexpense, token);
      notifyListeners();
    }catch (e){
      print('Failed to update expense: $e');
    }
  }

  Future<void> deleteExpense(int expenseId,int userid,String token) async {
    try {
      await repository.deleteExpense(DeleteExpense(expenseId: expenseId),userid,token);
      notifyListeners();
      print('Transaction deleted successfully!');
      // Refresh the transaction list after deletion
      await fetchListExpense(userid,token);
      await fetchViewExpense(userid,token);
    } catch (e) {
      print('Failed to delete transaction: $e');
    }
  }

  @override
  void dispose() {
    _repository.dispose(); // Call repository's dispose method
    super.dispose();
    print("ViewModel disposed.");
  }
}