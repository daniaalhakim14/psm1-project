// A bridge between view layer and repository (data layer)

import 'package:flutter/material.dart';
import '../../Model/Category.dart';
import 'addexpense_repository.dart';


// ChangeNotifier allows View Model to notify listeners when data changes
class expenseCategoryViewModel extends ChangeNotifier{

  final repository = expenseCategoryRepository();
  final expenseCategoryRepository _repository = expenseCategoryRepository();

  bool fetchingData = false;

  List<Category> _category = [];
  List<Category> get category => _category;

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



  @override
  void dispose() {
    _repository.dispose(); // Call repository's dispose method
    super.dispose();
    print("ViewModel disposed.");
  }


}





