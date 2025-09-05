import 'package:flutter/material.dart';
import 'package:fyp/ViewModel/taxMapping/taxMapping_repository.dart';

import '../../Model/taxMapping.dart';


class TaxMappingViewModel extends ChangeNotifier {
  final TaxMappingRepository _repository = TaxMappingRepository();
  MappedTaxRelief? _mappedResult;

  MappedTaxRelief? get mappedResult => _mappedResult;

  Future<void> mapTax(Map<String, dynamic> expensePayload, String token) async {
    final result = await _repository.processTaxMapping(expensePayload, token);
    if (result != null && result.isEligible) {
      _mappedResult = result;
      notifyListeners();
    }
  }
}
