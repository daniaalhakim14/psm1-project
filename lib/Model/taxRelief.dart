import 'package:flutter/material.dart';

class TotalCanClaim {
  final double totalRelief;

  TotalCanClaim({
    required this.totalRelief
  });

  factory TotalCanClaim.fromJson(Map<String, dynamic> json) => TotalCanClaim(
    totalRelief: _parseDouble(json['totalamount']), // Note: PostgreSQL returns lowercase
  );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class TotalEligibleClaim{
  final double claimedamount;
  TotalEligibleClaim({
    required this.claimedamount
  });

  factory TotalEligibleClaim.fromJson(Map<String, dynamic> json) => TotalEligibleClaim(
    claimedamount: _parseDouble(json['claimedamount']), // Note: PostgreSQL returns lowercase
  );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

}

class TaxReliefCategory{
  final int relieftypeid;
  final String relieftype;
  final double amountCanClaim;
  final double eligibleAmount;

  TaxReliefCategory({
    required this.relieftypeid,
    required this.relieftype,
    required this.amountCanClaim,
    required this.eligibleAmount
});
  factory TaxReliefCategory.fromJson(Map<String, dynamic> json) => TaxReliefCategory(
      relieftypeid: int.tryParse(json['relieftypeid'].toString()) ?? 0,
      relieftype:  json['relieftype'],
      amountCanClaim: _parseDouble(json['amountCanClaim']),
      eligibleAmount: _parseDouble(json['eligibleAmount'])
  );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

}

class ReliefTypeInfo{
  final String relieftype;
  final double totalRelief;
  final double totalclaimedamount;
  final String typeDescription;

  ReliefTypeInfo({
    required this.relieftype,
    required this.totalRelief,
    required this.totalclaimedamount,
    required this.typeDescription,
});
  factory ReliefTypeInfo.fromJson(Map<String, dynamic> json) => ReliefTypeInfo(
    relieftype: json['relieftype'] ?? '',
    totalRelief: _parseDouble(json['totalrelief']), // <-- fix key name
    totalclaimedamount: _parseDouble(json['claimedamount']), // <-- fix key name
    typeDescription: json['description'] ?? '',
  );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

}

class ReliefCategoryInfo{
  final String reliefcategory;
  final double totalCategoryRelief;
  final double totalCategoryClaimedAmount;
  final String description;

  ReliefCategoryInfo({
    required this.reliefcategory,
    required this.totalCategoryClaimedAmount,
    required this.totalCategoryRelief,
    required this.description
});

  factory ReliefCategoryInfo.fromJson(Map<String, dynamic> json) => ReliefCategoryInfo(
    reliefcategory: json['reliefcategory'] ?? '',
    totalCategoryRelief: _parseDouble(json['totalcategoryrelief']),
    totalCategoryClaimedAmount: _parseDouble(json['totalcategoryclaimedamount']),
    description: json['description'] ?? '',

  );
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

