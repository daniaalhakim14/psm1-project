import 'dart:io';

import 'package:flutter/material.dart';

class AddExpense {
  final double? expenseAmount;
  final DateTime? expenseDate;
  final String? expenseDescription;
  final int? financialPlatform;
  final int? userId;
  final int? categoryId;
  final String? receiptPdf;

  AddExpense({
    this.expenseAmount,
    this.expenseDate,
    this.expenseDescription,
    this.financialPlatform,
    this.userId,
    this.categoryId,
    this.receiptPdf,
  });

  factory AddExpense.fromJson(Map<String, dynamic> json) => AddExpense(
    expenseAmount: json["amount"],
    expenseDate: DateTime.parse(json["date"]),
    // Parse string to DateTime
    expenseDescription: json["description"],
    financialPlatform: json["platformId"],
    userId: json["userId"],
    categoryId: json["categoryId"],
  );

  Map<String, dynamic> toMap() {
    return {
      "amount": expenseAmount,
      "date": expenseDate?.toIso8601String(), // Convert DateTime to string
      "description": expenseDescription,
      "platformId": financialPlatform,
      "userId": userId,
      "categoryId": categoryId,
      "receipt": receiptPdf,
    };
  }
}

class ViewExpense{
  final int? expenseid;
  final double? expenseAmount;
  final DateTime? expenseDate;
  final String? expenseDescription;
  final int? financialPlatform;
  final int? userId;
  final int? categoryId;
  final String? receiptPdf;
  final IconData? iconData; // Combines `codepoint` and `fontfamily`
  final Color? iconColor;
  final String? categoryname;

  ViewExpense({
    this.expenseid,
    this.expenseAmount,
    this.expenseDate,
    this.expenseDescription,
    this.financialPlatform,
    this.userId,
    this.categoryId,
    this.receiptPdf,
    this.iconColor,
    this.iconData,
    this.categoryname,
  });

  factory ViewExpense.fromJson(Map<String, dynamic> json) => ViewExpense(
    expenseid: int.tryParse(json['expenseid'].toString().trim()) ?? 0,
    expenseAmount: double.parse(json['amount']),
    expenseDate: DateTime.parse(json["date"]),
    // Parse string to DateTime
    expenseDescription: json["description"],
    financialPlatform: int.tryParse(json["platformId"].toString()),
    userId: int.tryParse(json["userid"].toString()),
    categoryId: int.tryParse(json["categoryId"].toString()),
    iconData:
    (json['iconcodepoint'] != null && json['iconfontfamily'] != null)
        ? IconData(
      // Safely parse codepoint: supports both int and string
      json['iconcodepoint'] is int
          ? json['iconcodepoint']
          : int.tryParse(json['iconcodepoint'].toString()) ?? 0,
      fontFamily: json['iconfontfamily'],
    )
        : null, // fallback to null if incomplete icon data
    iconColor:
    json['iconcolor'] != null
        ? Color(
      // Safely parse color from int or string
      json['iconcolor'] is int
          ? json['iconcolor']
          : int.tryParse(json['iconcolor'].toString()) ?? 0,
    )
        : null,
    categoryname: json['categoryname'],
  );

}

class ListExpense{
  final int? expenseid;
  final double? expenseAmount;
  final DateTime? expenseDate;
  final String? categoryname;
  final String? expenseDescription;
  final String? paymenttype;
  final String? receiptPdf;
  final int? userId;
  final IconData? iconData;
  final Color? iconColor;

  ListExpense({
    this.expenseid,
    this.expenseAmount,
    this.expenseDate,
    this.categoryname,
    this.expenseDescription,
    this.paymenttype,
    this.receiptPdf,
    this.userId,
    this.iconData,
    this.iconColor
});
  factory ListExpense.fromJson(Map<String, dynamic> json) => ListExpense(
    expenseid: int.tryParse(json['expenseid'].toString().trim()) ?? 0,
    expenseAmount: double.parse(json['amount']),
    expenseDate: DateTime.parse(json["date"]),
    categoryname: json['categoryname'],
    expenseDescription: json['description'],
    paymenttype: json['paymenttype'],
    receiptPdf: json['receipt'],
    userId: int.tryParse(json["userid"].toString()),
    iconData:
    (json['iconcodepoint'] != null && json['iconfontfamily'] != null)
        ? IconData(
      // Safely parse codepoint: supports both int and string
      json['iconcodepoint'] is int
          ? json['iconcodepoint']
          : int.tryParse(json['iconcodepoint'].toString()) ?? 0,
      fontFamily: json['iconfontfamily'],
    )
        : null,
    iconColor: json['iconcolor'] != null
        ? Color(int.tryParse(json['iconcolor']) ?? 0) // Safely parse the color string
        : null,
  );

}

class DeleteExpense {
  final int expenseId; // The ID of the expense to be deleted

  DeleteExpense({
    required this.expenseId,
  });

  // Construct a DeleteExpense instance from JSON
  factory DeleteExpense.fromJson(Map<String, dynamic> json) {
    return DeleteExpense(
      expenseId: json['expenseid'],
    );
  }

  // Convert DeleteExpense object to a Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'expenseid': expenseId,
    };
  }
}
