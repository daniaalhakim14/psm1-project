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
  List<Category> _category = [];
  List<Category> get category => _category;
  List<ViewExpense> _ViewExpense = [];
  List<ViewExpense> get viewExpense => _ViewExpense;
  List<ListExpense> _listExpense = [];
  List<ListExpense> get listExpense => _listExpense;

  Future<void> fetchCategories() async {
    fetchingData = true;
    notifyListeners();

    try {
      _category = await repository.getCategories();
      //print('Loaded Categories: $_category');
    } catch (e) {
      print('Failed to load Basic Category: $e');
      _category = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(AddExpense expense, String token) async{
    try{
      await repository.addExpense(expense,token);
    }catch (e){
      print('Failed to add new expense: $e');
    }
  }

  Future<void> fetchViewExpense(int userid, String token) async {
    fetchingData = true; // Indicate that data fetching is in progress
    notifyListeners();
    try {
      _ViewExpense = await repository.getViewExpense(userid,token);
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
      _listExpense = await repository.getListExpense(userid, token);
    }catch(e){
      print('Failed to load list expense: $e');
      _listExpense = [];
    } finally{
      fetchingData = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.dispose(); // Call repository's dispose method
    super.dispose();
    print("ViewModel disposed.");
  }


}





