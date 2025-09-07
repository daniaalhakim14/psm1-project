// Total Amount of Tax Relief Can claim
class TotalCanClaim {
  final double totalRelief;

  TotalCanClaim({required this.totalRelief});

  factory TotalCanClaim.fromJson(Map<String, dynamic> json) => TotalCanClaim(
    totalRelief: _parseDouble(
      json['totalamount'],
    ), // Note: PostgreSQL returns lowercase
  );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// Total Amount of Tax Relief Eligible claimed
class TotalEligibleClaim {
  final double claimedamount;
  TotalEligibleClaim({required this.claimedamount});

  factory TotalEligibleClaim.fromJson(Map<String, dynamic> json) =>
      TotalEligibleClaim(
        claimedamount: _parseDouble(
          json['claimedamount'],
        ), // Note: PostgreSQL returns lowercase
      );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// For Main tax Mapping page show Brief info of Category Name, Amount Can Claim & Amount eligible Claim
class TaxReliefCategory {
  final int reliefcategoryid;
  final String categoryName;
  final double
  amountCanClaim; // To show the total Amount of Tax Relief Can claim for all categoory
  final double
  eligibleAmount; // To show the total Amount of Tax Relief Eligible claimed for all category
  final String? description; // Category Desciption
  final double?
  totalCategoryRelief; // To show total Amount of Tax Relief Can claim for a category
  final double?
  totalCategoryClaimedAmount; // To show total Amount of Tax Relief Eligible claimed for acategory
  final List<int>? iconImage; // Category icon image bytes from backend

  TaxReliefCategory({
    required this.reliefcategoryid,
    required this.categoryName,
    required this.amountCanClaim,
    required this.eligibleAmount,
    this.description,
    this.totalCategoryRelief,
    this.totalCategoryClaimedAmount,
    this.iconImage,
  });

  factory TaxReliefCategory.fromJson(Map<String, dynamic> json) {
    // Handle both API response formats
    return TaxReliefCategory(
      reliefcategoryid:
          int.tryParse(json['reliefcategoryid']?.toString() ?? '0') ?? 0,
      categoryName:
          json['categoryName']?.toString() ??
          json['categoryname']?.toString() ??
          '',
      amountCanClaim: _parseDouble(json['amountCanClaim']),
      eligibleAmount: _parseDouble(json['eligibleAmount']),
      description: json['description'],
      totalCategoryRelief: _parseDouble(json['totalCategoryRelief']),
      totalCategoryClaimedAmount: _parseDouble(
        json['totalCategoryClaimedAmount'],
      ),
      iconImage: _parseIconImage(
        json['iconimage'],
      ), // Safely parse the icon image
    );
  }

  // Convenience getters for backward compatibility
  double get totalUsed => totalCategoryClaimedAmount ?? eligibleAmount;
  double get totalAvailable => totalCategoryRelief ?? amountCanClaim;
  bool get hasDetailedInfo => description != null;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static List<int>? _parseIconImage(dynamic value) {
    if (value == null) return null;
    if (value is List<int>) return value;
    if (value is Map<String, dynamic>) {
      // Handle Buffer object from backend
      if (value['type'] == 'Buffer' && value['data'] is List) {
        try {
          // Convert buffer data to List<int>
          return List<int>.from(value['data']);
        } catch (e) {
          print('❌ Error converting buffer to bytes: $e');
          return null;
        }
      }
    }
    return null;
  }
}

// Eligible Expense model for individual expense details
class EligibleExpense {
  final int expenseid;
  final String expensename;
  final double amount;
  final String? date;
  final String? description;
  final String? receipt;
  final double eligibleamount;
  final double? confidence;
  final String? reasoning;

  EligibleExpense({
    required this.expenseid,
    required this.expensename,
    required this.amount,
    this.date,
    this.description,
    this.receipt,
    required this.eligibleamount,
    this.confidence,
    this.reasoning,
  });

  factory EligibleExpense.fromJson(Map<String, dynamic> json) {
    return EligibleExpense(
      expenseid: int.tryParse(json['expenseid']?.toString() ?? '0') ?? 0,
      expensename: json['expensename']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      date: json['date']?.toString(),
      description: json['description']?.toString(),
      receipt: json['receipt']?.toString(),
      eligibleamount: _parseDouble(json['eligibleamount']),
      confidence: _parseDouble(json['confidence']),
      reasoning: json['reasoning']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() {
    return 'EligibleExpense{'
        'expenseid: $expenseid, '
        'expensename: "$expensename", '
        'amount: RM$amount, '
        'eligibleamount: RM$eligibleamount, '
        'confidence: ${confidence != null ? '${(confidence! * 100).toInt()}%' : 'null'}, '
        'date: $date, '
        'reasoning: "${reasoning ?? 'null'}"'
        '}';
  }
}

class TaxReliefItem {
  final int reliefitemid;
  final String itemname;
  final double amountCanClaim;
  final double eligibleAmount;
  final String? description; // Category Desciption
  final double?
  totalItemReliefLimit; // To show total Amount of Tax Relief Can claim for a item
  final double?
  totalItemClaimedAmount; // To show total Amount of Tax Relief Eligible claimed for a item
  final String? receipt; // Receipt from eligible expenses
  final String? expensename; // Expense name from eligible expenses
  final double? expenseamount; // Expense amount from eligible expenses
  final List<EligibleExpense>?
  eligibleExpenses; // List of all eligible expenses

  TaxReliefItem({
    required this.reliefitemid,
    required this.itemname,
    required this.amountCanClaim,
    required this.eligibleAmount,
    this.description,
    this.totalItemReliefLimit,
    this.totalItemClaimedAmount,
    this.receipt,
    this.expensename,
    this.expenseamount,
    this.eligibleExpenses,
  });
  factory TaxReliefItem.fromJson(Map<String, dynamic> json) => TaxReliefItem(
    reliefitemid: int.tryParse(json['reliefitemid'].toString()) ?? 0,
    itemname: json['itemname'] ?? '',
    amountCanClaim: _parseDouble(json['amountCanClaim']),
    eligibleAmount: _parseDouble(json['eligibleAmount']),
    description: json['description']?.toString(),
    totalItemReliefLimit: _parseDouble(json['totalItemReliefLimit']),
    totalItemClaimedAmount: _parseDouble(json['totalItemClaimedAmount']),
    receipt: json['receipt']?.toString(),
    expensename: json['expensename']?.toString(),
    expenseamount: _parseDouble(json['expenseamount']),
    eligibleExpenses:
        json['eligibleexpenses'] != null
            ? (json['eligibleexpenses'] as List<dynamic>)
                .map((e) => EligibleExpense.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
  );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
