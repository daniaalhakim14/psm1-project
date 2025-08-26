//The repository centralizes all data-fetching and data-processing
// logic in one place
import 'dart:convert';
import '../../Model/Category.dart';
import '../../Model/expense.dart';
import 'expense_callapi.dart';

class expenseCategoryRepository{
  final expense_callApi _service = expense_callApi();

  Future<List<ExpenseCategories>> getCategories() async {
    final response = await _service.fetchCategories();

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      //print('Decoded Categories: $data');
      return List<ExpenseCategories>.from(
          data.map((x) => ExpenseCategories.fromJson(x))
      );
    } else {
      print('API Error: ${response.body}');
      throw Exception('Failed to load Categories');
    }
  }

  Future<void> addExpense(AddExpense expense,String token) async{
    final response = await _service.addExpense(expense.toMap(),token);
    final data = jsonDecode(response.body);
    // Log the response for debugging
    // print("Response status: ${response.statusCode}");
    //print("Response body: ${response.body}");
    if (response.statusCode != 201) {
      throw Exception('Failed to add expense to database: ${response.body}');
    }
  }

  Future<List<ViewExpense>> getViewExpense(int userid, String token) async {
    final response = await _service.fetchViewExpense(userid, token);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // This is a list of maps

      // Print raw JSON response from backend
      //print('Raw Expense Data from API: ${response.body}');
      final expenses = List<ViewExpense>.from(
        data.map((x) => ViewExpense.fromJson(x)),
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
      throw Exception('Failed to load Transaction Expense');
    }
  }

  Future<List<ListExpense>> getListExpense(int userid, String token)async{
    try{
      final response = await _service.fetchListExpense(userid, token);

      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        return List<ListExpense>.from(data.map((x) => ListExpense.fromJson(x)));
      }else {
        print('API Error: ${response.body}');
        throw Exception('Failed to load Expense List');
      }
    }catch (e) {
      print('Error fetching Expense List: $e');
      rethrow; // Allow ViewModel to handle it
    }
  }

  Future<List<ViewExpenseFinancialPlatform>> getViewExpenseFinancialPlatform(int userid, String token) async {
    final response = await _service.fetchViewExpenseFinancialPlatform(userid, token);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // This is a list of maps
      // Print raw JSON response from backend
      //print('Raw Expense Data from API: ${response.body}');
      final expenses = List<ViewExpenseFinancialPlatform>.from(
        data.map((x) => ViewExpenseFinancialPlatform.fromJson(x)),
      );
      //print('Financial Platform: $expenses');
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
      throw Exception('Failed to load financial platform Expense');
    }
  }

  Future<void> updateExpense(UpdateExpense updateexpense, String token) async {
    final response = await _service.updateExpense(updateexpense.expenseId!,   // use expenseId for URL
      updateexpense.toMap(),      // send body
      token,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception('Failed to update expense: ${response.body}');
    }
  }

  Future<void> deleteExpense(DeleteExpense deleteExpense, int userid, String token) async {
    final response = await _service.deleteExpense(deleteExpense.expenseId,userid,token);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete expense: ${response.body}');
    }

    print('Expense deleted successfully');
  }

  // Add a dispose method to clean up resources
  void dispose() {
    _service.dispose(); // Call dispose in the service
    print("Repository resources cleaned up.");
  }
}