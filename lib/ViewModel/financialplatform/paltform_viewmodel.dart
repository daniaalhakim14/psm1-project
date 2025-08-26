import 'package:flutter/cupertino.dart';
import 'package:fyp/ViewModel/financialplatform/paltform_repository.dart';

import '../../Model/financialplatformcategory.dart';

class platformViewModel extends ChangeNotifier {
  final repository = platformRepository();
  final platformRepository _repository = platformRepository();

  bool fetchingData = false;
  List<FinancialPlatform> _FPcategory = [];
  List<FinancialPlatform> get FPcategory => _FPcategory;

  // Financial Platform Categories
  Future<void> fetchFPCategories() async {
    fetchingData = true;
    notifyListeners();
    try {
      _FPcategory = await repository.getFPCategories();
      //print('Loaded Financial Platform: $_FPcategory');
    } catch (e) {
      print('Failed to load Financial Platform Category: $e');
      _FPcategory = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

}