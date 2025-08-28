import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class AddExpense {
  final double? expenseAmount;
  final DateTime? expenseDate;
  final String? expenseName;
  final String? expenseDescription;
  final int? financialPlatformId;
  final int? userId;
  final int? categoryId;
  final String? receiptPdf;

  AddExpense({
    this.expenseAmount,
    this.expenseDate,
    this.expenseName,
    this.expenseDescription,
    this.financialPlatformId,
    this.userId,
    this.categoryId,
    this.receiptPdf,
  });

  factory AddExpense.fromJson(Map<String, dynamic> json) => AddExpense(
    expenseAmount: json["amount"],
    expenseDate: DateTime.parse(json["date"]),
    // Parse string to DateTime
    expenseName: json['expensename'],
    expenseDescription: json["description"],
    financialPlatformId: json['platformid'],
    userId: json["userId"],
    categoryId: json["categoryId"],
    receiptPdf: json['receipt']
  );

  Map<String, dynamic> toMap() {
    return {
      "amount": expenseAmount,
      "date": expenseDate?.toIso8601String(), // Convert DateTime to string
      "expensename": expenseName,
      "description": expenseDescription,
      "platformid": financialPlatformId,
      "userId": userId,
      "categoryId": categoryId,
      "receipt": receiptPdf,
    };
  }
}

class ViewExpense{
  final int? expenseid;
  final double? expenseAmount;
  final String? expenseName;
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
    this.expenseName,
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
    expenseName: json['expensename'],
    // Parse string to DateTime
    expenseDescription: json["description"],
    financialPlatform: int.tryParse(json["platformId"].toString()),
    userId: int.tryParse(json["userid"].toString()),
    categoryId: int.tryParse(json["categoryId"].toString()),
    iconData: (json['iconcodepoint'] != null && json['iconfontfamily'] != null) ? IconData(
      // Safely parse codepoint: supports both int and string
      json['iconcodepoint'] is int ? json['iconcodepoint'] : int.tryParse(json['iconcodepoint'].toString()) ?? 0,
      fontFamily: json['iconfontfamily'],
    ) : null, // fallback to null if incomplete icon data
    iconColor: json['iconcolor'] != null ? Color(
      // Safely parse color from int or string
      json['iconcolor'] is int ? json['iconcolor'] : int.tryParse(json['iconcolor'].toString()) ?? 0,
    ) : null,
    categoryname: json['categoryname'],
  );

}

class ListExpense{
  late final int? expenseid;
  final double? expenseAmount;
  final DateTime? expenseDate;
  final String? expenseName;
  final int? categoryid;
  final String? categoryname;
  final String? expenseDescription;
  final String? paymenttype;
  final String? receiptPdf;
  final int? userId;
  final IconData? iconData;
  final Color? iconColor;
  final int? platformid;
  final String? name; // financial platform name
  final Color? iconColorExpense;
  final Uint8List? iconimage; // financial platform icon

  ListExpense({
    this.expenseid,
    this.expenseAmount,
    this.expenseDate,
    this.expenseName,
    this.categoryid,
    this.categoryname,
    this.expenseDescription,
    this.paymenttype,
    this.receiptPdf,
    this.userId,
    this.iconData,
    this.iconColor,
    this.platformid,
    this.name,
    this.iconColorExpense,
    this.iconimage
  });
  factory ListExpense.fromJson(Map<String, dynamic> json){
    Uint8List? iconBytes;
    final rawIcon = json['iconimage'];

    if (rawIcon == null) {
      iconBytes = null;
    } else if (rawIcon is Map<String, dynamic>) {
      // Node Buffer -> { type: 'Buffer', data: [...] }
      final data = rawIcon['data'];
      if (data is List) {
        iconBytes = Uint8List.fromList(List<int>.from(data));
      }
    } else if (rawIcon is List) {
      // Already a List<int>
      iconBytes = Uint8List.fromList(List<int>.from(rawIcon));
    } else if (rawIcon is String) {
      // Base64 string
      try {
        iconBytes = base64Decode(rawIcon);
      } catch (_) {
        iconBytes = null;
      }
    }
    return ListExpense(
      expenseid: int.tryParse(json['expenseid'].toString().trim()) ?? 0,
      expenseAmount: double.parse(json['amount']),
      expenseDate: DateTime.parse(json["date"]),
      expenseName: json['expensename'],
      categoryid: int.tryParse(json['categoryid'].toString().trim()) ?? 0,
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
      iconColor: json['iconcolor'] != null ? Color(int.tryParse(json['iconcolor']) ?? 0) // Safely parse the color string
          : null,
      platformid: int.tryParse(json['platformid']?.toString().trim() ?? ''),
      name: json['name']?.toString(),
      iconColorExpense: json['iconcolorexpense'] != null ? Color(int.tryParse(json['iconcolorexpense']) ?? 0) // Safely parse the color string
          : null,
      iconimage: iconBytes,
    );
  }
}

class ViewExpenseFinancialPlatform {
  final int? expenseid;
  final int? platformid;
  final double? expenseAmount;
  final String? name; // financial platform name
  final DateTime? expenseDate;
  final int? userId;
  final Color? iconColor;
  final Uint8List? iconimage; // financial platform icon

  ViewExpenseFinancialPlatform({
    this.expenseid,
    this.platformid,
    this.expenseAmount,
    this.expenseDate,
    this.name,
    this.userId,
    this.iconColor,
    this.iconimage
  });

  factory ViewExpenseFinancialPlatform.fromJson(Map<String, dynamic> json) {
    Uint8List? iconBytes;
    final rawIcon = json['iconimage'];

    if (rawIcon == null) {
      iconBytes = null;
    } else if (rawIcon is Map<String, dynamic>) {
      // Node Buffer -> { type: 'Buffer', data: [...] }
      final data = rawIcon['data'];
      if (data is List) {
        iconBytes = Uint8List.fromList(List<int>.from(data));
      }
    } else if (rawIcon is List) {
      // Already a List<int>
      iconBytes = Uint8List.fromList(List<int>.from(rawIcon));
    } else if (rawIcon is String) {
      // Base64 string
      try {
        iconBytes = base64Decode(rawIcon);
      } catch (_) {
        iconBytes = null;
      }
    }

    return ViewExpenseFinancialPlatform(
      expenseid: int.tryParse(json['expenseid'].toString().trim()) ?? 0,
      platformid: int.tryParse(json['platformid']?.toString().trim() ?? ''),
      expenseAmount: double.tryParse(json['amount'].toString()),
      expenseDate: DateTime.parse(json['date'].toString()),
      name: json['name']?.toString(),
      userId: int.tryParse(json['userid'].toString().trim()),
      iconColor: json['iconcolorexpense'] != null ? Color(
        // Safely parse color from int or string
        json['iconcolorexpense'] is int ? json['iconcolorexpense'] : int.tryParse(json['iconcolorexpense'].toString()) ?? 0,
      ) : null,
      iconimage: iconBytes,
    );
  }
}

class UpdateExpense {
  final int? expenseId;
  final double? expenseAmount;
  final DateTime? expenseDate;
  final String? expenseName;
  final String? expenseDescription;
  final int? financialPlatform;
  final int? userId;
  final int? categoryId;

  UpdateExpense({
    this.expenseId,
    this.expenseAmount,
    this.expenseDate,
    this.expenseName,
    this.expenseDescription,
    this.financialPlatform,
    this.userId,
    this.categoryId,
  });

  factory UpdateExpense.fromJson(Map<String, dynamic> json) => UpdateExpense(
    expenseId: int.tryParse(json['expenseid'].toString().trim()) ?? 0,
    expenseAmount: json["amount"],
    expenseDate: DateTime.parse(json["date"].toString()),
    expenseName: json['expensename']?.toString().trim(),
    expenseDescription: json["description"]?.toString().trim(),
    financialPlatform: int.tryParse(json["platformid"].toString().trim()),
    userId: int.tryParse(json["userid"].toString().trim()),
    categoryId: int.tryParse(json["categoryid"].toString().trim()),
  );


  Map<String, dynamic> toMap() {
    return {
      "amount": expenseAmount,
      "date": expenseDate?.toIso8601String(),
      "description": expenseDescription,
      "platformid": financialPlatform?.toString().trim(), // 👈
      "userid": userId?.toString().trim(),                // 👈 matches your backend’s current key
      "categoryid": categoryId?.toString().trim(),        // 👈
      "expensename": expenseName,
    };
  }
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