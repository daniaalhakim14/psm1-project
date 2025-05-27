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
  final String? categoryName;

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
    this.categoryName,
  });

  factory ViewExpense.fromJson(Map<String, dynamic> json) => ViewExpense(
    expenseid: json['expenseid'],
    expenseAmount: json["amount"],
    expenseDate: DateTime.parse(json["date"]),
    // Parse string to DateTime
    expenseDescription: json["description"],
    financialPlatform: json["platformId"],
    userId: json["userid"],
    categoryId: json["categoryId"],
    iconData:
    (json['iconCodePoint'] != null && json['iconFontFamily'] != null)
        ? IconData(
      // Safely parse codepoint: supports both int and string
      json['iconCodePoint'] is int
          ? json['iconCodePoint']
          : int.tryParse(json['iconCodePoint'].toString()) ?? 0,
      fontFamily: json['iconFontFamily'],
    )
        : null, // fallback to null if incomplete icon data
    iconColor:
    json['iconColor'] != null
        ? Color(
      // Safely parse color from int or string
      json['iconColor'] is int
          ? json['iconColor']
          : int.tryParse(json['iconColor'].toString()) ?? 0,
    )
        : null,
    categoryName: json['categoryName'],
  );
}
