class MappedTaxRelief {
  final int? expenseId;
  final int? categoryId;
  final String? possibleTaxKeyword;
  final bool isEligible;

  MappedTaxRelief({
    this.expenseId,
    this.categoryId,
    this.possibleTaxKeyword,
    this.isEligible = false,
  });

  factory MappedTaxRelief.fromJson(Map<String, dynamic> json) {
    return MappedTaxRelief(
      expenseId: json['expenseId'],
      categoryId: json['categoryId'],
      possibleTaxKeyword: json['possibleTaxKeyword'],
      isEligible: json['isEligible'],
    );
  }
}
