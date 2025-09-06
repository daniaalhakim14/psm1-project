class MappedTaxRelief {
  final bool success;
  final TaxMappingData? data;
  final ExpenseDetails? expenseDetails;
  final String? error;

  MappedTaxRelief({
    this.success = false,
    this.data,
    this.expenseDetails,
    this.error,
  });

  factory MappedTaxRelief.fromJson(Map<String, dynamic> json) {
    return MappedTaxRelief(
      success: json['success'] ?? false,
      data: json['data'] != null ? TaxMappingData.fromJson(json['data']) : null,
      expenseDetails:
          json['expenseDetails'] != null
              ? ExpenseDetails.fromJson(json['expenseDetails'])
              : null,
      error: json['error'],
    );
  }

  bool get isEligible => success && data?.eligible == true;
}

class TaxMappingData {
  final bool eligible;
  final List<TaxMatch>? matches;
  final String? totalReliefAmount;
  final String? recommendations;
  final String? rawText;

  TaxMappingData({
    this.eligible = false,
    this.matches,
    this.totalReliefAmount,
    this.recommendations,
    this.rawText,
  });

  factory TaxMappingData.fromJson(Map<String, dynamic> json) {
    return TaxMappingData(
      eligible: json['eligible'] ?? false,
      matches:
          json['matches'] != null
              ? List<TaxMatch>.from(
                json['matches'].map((x) => TaxMatch.fromJson(x)),
              )
              : null,
      totalReliefAmount: json['totalReliefAmount'],
      recommendations: json['recommendations'],
      rawText: json['rawText'],
    );
  }
}

class TaxMatch {
  final String? categoryId;
  final String? categoryName;
  final String? itemId;
  final String? itemName;
  final String? reliefAmount;
  final String? confidence;
  final String? reasoning;

  TaxMatch({
    this.categoryId,
    this.categoryName,
    this.itemId,
    this.itemName,
    this.reliefAmount,
    this.confidence,
    this.reasoning,
  });

  factory TaxMatch.fromJson(Map<String, dynamic> json) {
    return TaxMatch(
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName'],
      itemId: json['itemId']?.toString(),
      itemName: json['itemName'],
      reliefAmount: json['reliefAmount']?.toString(),
      confidence: json['confidence']?.toString(),
      reasoning: json['reasoning'],
    );
  }
}

class ExpenseDetails {
  final int? expenseId;
  final double? amount;
  final String? date;
  final String? description;
  final String? expenseName;
  final String? categoryName;
  final String? platformName;

  ExpenseDetails({
    this.expenseId,
    this.amount,
    this.date,
    this.description,
    this.expenseName,
    this.categoryName,
    this.platformName,
  });

  factory ExpenseDetails.fromJson(Map<String, dynamic> json) {
    return ExpenseDetails(
      expenseId: json['expenseid'],
      amount: json['amount']?.toDouble(),
      date: json['date'],
      description: json['description'],
      expenseName: json['expensename'],
      categoryName: json['categoryname'],
      platformName: json['platformname'],
    );
  }
}

// For sending requests to the backend
class TaxMappingRequest {
  final String base64Receipt;
  final int userId;

  TaxMappingRequest({required this.base64Receipt, required this.userId});

  Map<String, dynamic> toMap() {
    return {'base64Receipt': base64Receipt, 'userId': userId};
  }
}
