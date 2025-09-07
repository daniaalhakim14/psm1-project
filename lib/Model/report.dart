// Spending Analysis Models
class ExpenseSummary {
  final DateRange range;
  final String currency;
  final ExpenseTotals totals;
  final DailyAverageSpending dailyAverageSpending;
  final double monthlyAverageSpending;
  final ExpenseCategory biggestExpenseCategory;
  final MostUsedFinancialPlatform mostUsedFinancialPlatform;
  final List<TimeSeriesData> timeSeriesDaily;
  final List<CategoryBreakdown> breakdownByCategory;
  final List<PlatformBreakdown> breakdownByPlatform;
  final List<TopExpense> top5Expenses;

  ExpenseSummary({
    required this.range,
    required this.currency,
    required this.totals,
    required this.dailyAverageSpending,
    required this.monthlyAverageSpending,
    required this.biggestExpenseCategory,
    required this.mostUsedFinancialPlatform,
    required this.timeSeriesDaily,
    required this.breakdownByCategory,
    required this.breakdownByPlatform,
    required this.top5Expenses,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseSummary(
      range: DateRange.fromJson(json['range']),
      currency: json['currency'] ?? 'MYR',
      totals: ExpenseTotals.fromJson(json['totals']),
      dailyAverageSpending: DailyAverageSpending.fromJson(
        json['dailyAverageSpending'],
      ),
      monthlyAverageSpending: _parseDouble(json['monthlyAverageSpending']),
      biggestExpenseCategory: ExpenseCategory.fromJson(
        json['biggestExpenseCategory'],
      ),
      mostUsedFinancialPlatform: MostUsedFinancialPlatform.fromJson(
        json['mostUsedFinancialPlatform'],
      ),
      timeSeriesDaily:
          (json['timeSeriesDaily'] as List)
              .map((item) => TimeSeriesData.fromJson(item))
              .toList(),
      breakdownByCategory:
          (json['breakdownByCategory'] as List)
              .map((item) => CategoryBreakdown.fromJson(item))
              .toList(),
      breakdownByPlatform:
          (json['breakdownByPlatform'] as List)
              .map((item) => PlatformBreakdown.fromJson(item))
              .toList(),
      top5Expenses:
          (json['top5Expenses'] as List)
              .map((item) => TopExpense.fromJson(item))
              .toList(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class DateRange {
  final String start;
  final String end;

  DateRange({required this.start, required this.end});

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(start: json['start'] ?? '', end: json['end'] ?? '');
  }
}

class ExpenseTotals {
  final double sum;

  ExpenseTotals({required this.sum});

  factory ExpenseTotals.fromJson(Map<String, dynamic> json) {
    return ExpenseTotals(sum: _parseDouble(json['sum']));
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class DailyAverageSpending {
  final double calendarDays;
  final double activeDays;

  DailyAverageSpending({required this.calendarDays, required this.activeDays});

  factory DailyAverageSpending.fromJson(Map<String, dynamic> json) {
    return DailyAverageSpending(
      calendarDays: _parseDouble(json['calendarDays']),
      activeDays: _parseDouble(json['activeDays']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class ExpenseCategory {
  final int id;
  final String name;
  final double sum;

  ExpenseCategory({required this.id, required this.name, required this.sum});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      sum: _parseDouble(json['sum']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class MostUsedFinancialPlatform {
  final PlatformByCount byCount;
  final PlatformByAmount byAmount;

  MostUsedFinancialPlatform({required this.byCount, required this.byAmount});

  factory MostUsedFinancialPlatform.fromJson(Map<String, dynamic> json) {
    return MostUsedFinancialPlatform(
      byCount: PlatformByCount.fromJson(json['byCount']),
      byAmount: PlatformByAmount.fromJson(json['byAmount']),
    );
  }
}

class PlatformByCount {
  final int id;
  final String name;
  final int count;

  PlatformByCount({required this.id, required this.name, required this.count});

  factory PlatformByCount.fromJson(Map<String, dynamic> json) {
    return PlatformByCount(
      id: _parseInt(json['platformId'] ?? json['id']),
      name: (json['name'] ?? '').toString().trim(),
      count: _parseInt(json['count']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}

class PlatformByAmount {
  final int id;
  final String name;
  final double sum;

  PlatformByAmount({required this.id, required this.name, required this.sum});

  factory PlatformByAmount.fromJson(Map<String, dynamic> json) {
    return PlatformByAmount(
      id: _parseInt(json['platformId'] ?? json['id']),
      name: (json['name'] ?? '').toString().trim(),
      sum: _parseDouble(json['sum']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class TimeSeriesData {
  final String date;
  final double sum;

  TimeSeriesData({required this.date, required this.sum});

  factory TimeSeriesData.fromJson(Map<String, dynamic> json) {
    return TimeSeriesData(
      date: json['date'] ?? '',
      sum: _parseDouble(json['sum']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class CategoryBreakdown {
  final int categoryId;
  final String name;
  final double sum;

  CategoryBreakdown({
    required this.categoryId,
    required this.name,
    required this.sum,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryId: _parseInt(json['id'] ?? json['categoryId']),
      name: json['name'] ?? '',
      sum: _parseDouble(json['sum']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class PlatformBreakdown {
  final int platformId;
  final String name;
  final double sum;

  PlatformBreakdown({
    required this.platformId,
    required this.name,
    required this.sum,
  });

  factory PlatformBreakdown.fromJson(Map<String, dynamic> json) {
    return PlatformBreakdown(
      platformId: _parseInt(json['platformId'] ?? json['id']),
      name: json['name'] ?? '',
      sum: _parseDouble(json['sum']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class TopExpense {
  final int expenseid;
  final String name;
  final double amount;
  final String date;

  TopExpense({
    required this.expenseid,
    required this.name,
    required this.amount,
    required this.date,
  });

  factory TopExpense.fromJson(Map<String, dynamic> json) {
    return TopExpense(
      expenseid: _parseInt(json['expenseid'] ?? json['id']),
      name: json['name'] ?? '',
      amount: _parseDouble(json['amount']),
      date: json['date'] ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// Tax Relief Eligible Expenses Models
class TaxReliefEligibleReport {
  final int year;
  final List<TaxReliefCategory> categories;

  TaxReliefEligibleReport({required this.year, required this.categories});

  factory TaxReliefEligibleReport.fromJson(Map<String, dynamic> json) {
    return TaxReliefEligibleReport(
      year: json['year'] ?? DateTime.now().year,
      categories:
          (json['categories'] as List)
              .map((item) => TaxReliefCategory.fromJson(item))
              .toList(),
    );
  }
}

class TaxReliefCategory {
  final String reliefcategory;
  final List<TaxReliefItem> items;

  TaxReliefCategory({required this.reliefcategory, required this.items});

  factory TaxReliefCategory.fromJson(Map<String, dynamic> json) {
    return TaxReliefCategory(
      reliefcategory: json['reliefcategory'] ?? '',
      items:
          (json['items'] as List)
              .map((item) => TaxReliefItem.fromJson(item))
              .toList(),
    );
  }
}

class TaxReliefItem {
  final int reliefitemid;
  final String itemName;
  final double itemClaimLimit;
  final double itemTotalEligible;
  final double itemRemaining;
  final List<TaxReliefExpense> expenses;

  TaxReliefItem({
    required this.reliefitemid,
    required this.itemName,
    required this.itemClaimLimit,
    required this.itemTotalEligible,
    required this.itemRemaining,
    required this.expenses,
  });

  factory TaxReliefItem.fromJson(Map<String, dynamic> json) {
    return TaxReliefItem(
      reliefitemid: _parseInt(json['reliefitemid']),
      itemName: json['itemName'] ?? '',
      itemClaimLimit: _parseDouble(json['itemClaimLimit']),
      itemTotalEligible: _parseDouble(json['itemTotalEligible']),
      itemRemaining: _parseDouble(json['itemRemaining']),
      expenses:
          (json['expenses'] as List)
              .map((item) => TaxReliefExpense.fromJson(item))
              .toList(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class TaxReliefExpense {
  final int expenseid;
  final String name;
  final double amount;
  final double eligibleamount;
  final String date;
  final bool hasReceipt;

  TaxReliefExpense({
    required this.expenseid,
    required this.name,
    required this.amount,
    required this.eligibleamount,
    required this.date,
    required this.hasReceipt,
  });

  factory TaxReliefExpense.fromJson(Map<String, dynamic> json) {
    return TaxReliefExpense(
      expenseid: _parseInt(json['expenseid']),
      name: json['name'] ?? '',
      amount: _parseDouble(json['amount']),
      eligibleamount: _parseDouble(json['eligibleamount']),
      date: json['date'] ?? '',
      hasReceipt: json['hasReceipt'] ?? false,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// Filter Models
class ReportFilters {
  final String period; // 'month' or 'year'
  final int year;
  final int? month;
  final String timezone;

  ReportFilters({
    required this.period,
    required this.year,
    this.month,
    this.timezone = 'Asia/Kuala_Lumpur',
  });

  Map<String, dynamic> toQueryParams(int userId) {
    final params = {
      'userId': userId.toString(),
      'period': period,
      'year': year.toString(),
      'tz': timezone,
    };

    if (month != null) {
      params['month'] = month.toString();
    }

    return params;
  }
}
