import '../../Model/report.dart';

// Demo data service for testing the Report feature without backend
class DemoReportService {
  static ExpenseSummary getDemoExpenseSummary() {
    final demoData = {
      "range": {"start": "2025-09-01", "end": "2025-09-30"},
      "currency": "MYR",
      "totals": {"sum": 2450.75},
      "dailyAverageSpending": {"calendarDays": 81.69, "activeDays": 122.54},
      "monthlyAverageSpending": 2100.30,
      "biggestExpenseCategory": {"id": 3, "name": "Groceries", "sum": 820.40},
      "mostUsedFinancialPlatform": {
        "byCount": {"id": 2, "name": "Touch 'n Go", "count": 19},
        "byAmount": {"id": 5, "name": "Maybank Debit", "sum": 1400.10},
      },
      "timeSeriesDaily": [
        {"date": "2025-09-01", "sum": 120.50},
        {"date": "2025-09-02", "sum": 85.20},
        {"date": "2025-09-03", "sum": 250.75},
        {"date": "2025-09-04", "sum": 45.30},
        {"date": "2025-09-05", "sum": 799.00},
        {"date": "2025-09-06", "sum": 156.80},
        {"date": "2025-09-07", "sum": 89.40},
        {"date": "2025-09-08", "sum": 67.25},
        {"date": "2025-09-09", "sum": 234.60},
        {"date": "2025-09-10", "sum": 123.45},
      ],
      "breakdownByCategory": [
        {"categoryId": 3, "name": "Groceries", "sum": 820.40},
        {"categoryId": 1, "name": "Transport", "sum": 450.30},
        {"categoryId": 5, "name": "Entertainment", "sum": 380.25},
        {"categoryId": 2, "name": "Dining", "sum": 345.60},
        {"categoryId": 4, "name": "Shopping", "sum": 280.15},
        {"categoryId": 6, "name": "Utilities", "sum": 174.05},
      ],
      "breakdownByPlatform": [
        {"platformId": 5, "name": "Maybank Debit", "sum": 1400.10},
        {"platformId": 2, "name": "Touch 'n Go", "sum": 650.25},
        {"platformId": 1, "name": "Cash", "sum": 245.80},
        {"platformId": 3, "name": "Grab", "sum": 154.60},
      ],
      "top5Expenses": [
        {
          "expenseid": 101,
          "name": "iPhone 15",
          "amount": 799.00,
          "date": "2025-09-05",
        },
        {
          "expenseid": 102,
          "name": "Weekly Groceries",
          "amount": 250.75,
          "date": "2025-09-03",
        },
        {
          "expenseid": 103,
          "name": "Petrol",
          "amount": 156.80,
          "date": "2025-09-06",
        },
        {
          "expenseid": 104,
          "name": "Restaurant Dinner",
          "amount": 134.50,
          "date": "2025-09-09",
        },
        {
          "expenseid": 105,
          "name": "Movie & Snacks",
          "amount": 89.40,
          "date": "2025-09-07",
        },
      ],
    };

    return ExpenseSummary.fromJson(demoData);
  }

  static TaxReliefEligibleReport getDemoTaxReliefReport() {
    final demoData = {
      "year": 2025,
      "categories": [
        {
          "reliefcategory": "Education (Self)",
          "items": [
            {
              "reliefitemid": 12,
              "itemName": "Master's Degree Fees",
              "itemClaimLimit": 7000.0,
              "itemTotalEligible": 4200.0,
              "itemRemaining": 2800.0,
              "expenses": [
                {
                  "expenseid": 345,
                  "name": "UM Tuition Fee",
                  "amount": 3500.0,
                  "eligibleamount": 3500.0,
                  "date": "2025-03-20",
                  "hasReceipt": true,
                },
                {
                  "expenseid": 346,
                  "name": "Course Materials",
                  "amount": 800.0,
                  "eligibleamount": 700.0,
                  "date": "2025-02-15",
                  "hasReceipt": true,
                },
              ],
            },
          ],
        },
        {
          "reliefcategory": "Medical (Self)",
          "items": [
            {
              "reliefitemid": 8,
              "itemName": "Medical Treatment",
              "itemClaimLimit": 8000.0,
              "itemTotalEligible": 1250.0,
              "itemRemaining": 6750.0,
              "expenses": [
                {
                  "expenseid": 230,
                  "name": "Dental Checkup",
                  "amount": 450.0,
                  "eligibleamount": 450.0,
                  "date": "2025-06-10",
                  "hasReceipt": true,
                },
                {
                  "expenseid": 231,
                  "name": "Eye Examination",
                  "amount": 800.0,
                  "eligibleamount": 800.0,
                  "date": "2025-07-22",
                  "hasReceipt": true,
                },
              ],
            },
          ],
        },
        {
          "reliefcategory": "Lifestyle",
          "items": [
            {
              "reliefitemid": 15,
              "itemName": "Gym Membership",
              "itemClaimLimit": 2500.0,
              "itemTotalEligible": 1800.0,
              "itemRemaining": 700.0,
              "expenses": [
                {
                  "expenseid": 156,
                  "name": "Annual Gym Membership",
                  "amount": 1800.0,
                  "eligibleamount": 1800.0,
                  "date": "2025-01-15",
                  "hasReceipt": true,
                },
              ],
            },
            {
              "reliefitemid": 16,
              "itemName": "Sports Equipment",
              "itemClaimLimit": 1500.0,
              "itemTotalEligible": 650.0,
              "itemRemaining": 850.0,
              "expenses": [
                {
                  "expenseid": 178,
                  "name": "Running Shoes",
                  "amount": 350.0,
                  "eligibleamount": 350.0,
                  "date": "2025-04-08",
                  "hasReceipt": true,
                },
                {
                  "expenseid": 179,
                  "name": "Fitness Tracker",
                  "amount": 300.0,
                  "eligibleamount": 300.0,
                  "date": "2025-05-12",
                  "hasReceipt": false,
                },
              ],
            },
          ],
        },
      ],
    };

    return TaxReliefEligibleReport.fromJson(demoData);
  }

  // Demo method to simulate server-side PDF generation
  static Future<List<int>> generateDemoPdf() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Return empty bytes (in real implementation, this would be PDF bytes)
    return <int>[];
  }
}
