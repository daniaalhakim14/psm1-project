import 'dart:convert';
import 'package:fyp/ViewModel/financialplatform/platform_callapi.dart' show platform_callapi;
import '../../Model/expense.dart';
import '../../Model/financialplatformcategory.dart';


class platformRepository {
  final platform_callapi _service = platform_callapi();

  // Financial Platform Categories
  Future<List<FinancialPlatform>> getFPCategories() async{
    final response = await _service.fetchFPCategories();

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      //print('Decoded Categories: $data');
      return List<FinancialPlatform>.from(
          data.map((x) => FinancialPlatform.fromJson(x))
      );
    } else {
      print('API Error: ${response.body}');
      throw Exception('Failed to load Categories');
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
}