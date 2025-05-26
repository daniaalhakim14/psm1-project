//The repository centralizes all data-fetching and data-processing
// logic in one place
import 'dart:convert';
import '../../Model/category.dart';
import '../../Model/expense.dart';
import 'expense_callapi.dart';

class expenseCategoryRepository{
  final CallingApi _service = CallingApi();

  Future<List<Category>> getCategories() async {
    final response = await _service.fetchCategories();

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      // print('Decoded Categories: $data');
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


  // Add a dispose method to clean up resources
  void dispose() {
    _service.dispose(); // Call dispose in the service
    print("Repository resources cleaned up.");
  }


}