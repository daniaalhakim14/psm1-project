// A bridge between view layer and repository (data layer)
import 'package:flutter/material.dart';
import '../../Model/taxMapping.dart';
import 'taxMapping_repository.dart';

// ChangeNotifier allows View Model to notify listeners when data changes
class TaxMappingViewModel extends ChangeNotifier {
  final TaxMappingRepository _repository = TaxMappingRepository();

  bool fetchingData = false;
  MappedTaxRelief? _mappedResult;
  MappedTaxRelief? get mappedResult => _mappedResult;

  Future<MappedTaxRelief?> performTaxMappingForUser(
    String base64Pdf,
    int userId,
    String token,
  ) async {
    fetchingData = true;
    notifyListeners();

    try {
      _mappedResult = await _repository.processTaxMappingWithTimeout(
        base64Pdf,
        userId,
        token,
      );

      if (_mappedResult != null && _mappedResult!.isEligible) {
        print("Tax mapping successful - eligible for relief");
      } else {
        print("Tax mapping completed - not eligible for relief");
      }

      return _mappedResult;
    } catch (e) {
      print('Failed to perform tax mapping: $e');
      _mappedResult = null;
      return null;
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
    print("🧹 TaxMappingViewModel disposed.");
  }
}
