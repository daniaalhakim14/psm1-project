import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'receiptParser_repository.dart';

class ReceiptParserViewModel extends ChangeNotifier {
  final ReceiptParserRepository _repository = ReceiptParserRepository();

  Map<String, dynamic>? _parsedResult;
  Map<String, dynamic>? get parsedResult => _parsedResult;

  bool isLoading = false;
  bool uploadSuccess = false;
  String? errorMessage;

  /// Upload PDF and return success or error info
  Future<bool> uploadPdf(File pdfFile) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final parsed = await _repository.uploadReceiptPdf(pdfFile);
      if (parsed != null) {
        _parsedResult = parsed;
        uploadSuccess = true;
      } else {
        uploadSuccess = false;
        errorMessage = 'Failed to parse receipt.';
      }
    } catch (e) {
      uploadSuccess = false;
      errorMessage = 'Exception: ${e.toString()}';
    }

    isLoading = false;
    notifyListeners();
    return uploadSuccess;
  }

  Future<void> parseText(String text) async {
    isLoading = true;
    notifyListeners();

    _parsedResult = await _repository.parseReceipt(text);

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
