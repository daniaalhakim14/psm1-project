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
