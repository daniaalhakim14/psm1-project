//The repository centralizes all data-fetching and data-processing
// logic in one place
import 'dart:convert';
import '../../Model/Category.dart';
import '../../Model/expense.dart';
import 'expense_callapi.dart';

class expenseCategoryRepository{
  final expense_callApi _service = expense_callApi();

  Future<List<Category>> getCategories() async {
    final response = await _service.fetchCategories();

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      print('Decoded Categories: $data');
      return List<Category>.from(
          data.map((x) => Category.fromJson(x))
      );
    } else {
      print('API Error: ${response.body}');
      throw Exception('Failed to load Categories');
    }
  }

  Future<void> addExpense(AddExpense expense) async{
    final response = await _service.addExpense(expense.toMap());

    // Log the response for debugging
    // print("Response status: ${response.statusCode}");
    //print("Response body: ${response.body}");

    if (response.statusCode != 201) {
      throw Exception('Failed to add expense to database: ${response.body}');
    }
  }

  Future<List<ViewExpense>> getViewExpense(int userid) async{
    final response = await _service.fetchViewExpense(userid);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // This is a list of maps
      print('Decoded Transaction Expense: $data'); // Debugging log
      return List<ViewExpense>.from(
          data.map((x) => ViewExpense.fromJson(x)) // Map each item
      );
    } else {
      throw Exception('Failed to load Transaction Expense');
    }
  }
  // Add a dispose method to clean up resources
  void dispose() {
    _service.dispose(); // Call dispose in the service
    print("Repository resources cleaned up.");
  }
}


