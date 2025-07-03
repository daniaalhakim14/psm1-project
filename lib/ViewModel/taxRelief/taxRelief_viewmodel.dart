import 'package:flutter/material.dart';
import '../../Model/taxrelief.dart';
import 'taxRelief_repository.dart';

class TaxReliefViewModel extends ChangeNotifier {
  final TaxReliefRepository _repository = TaxReliefRepository();

  List<TaxRelief> _reliefs = [];
  List<TaxRelief> get reliefs => _reliefs;
  List<TaxRelief> _reliefsTypes = [];
  List<TaxRelief> get reliefsTypes => _reliefsTypes;


  bool fetchingData = false;

  Future<void> fetchTaxReliefs(String token) async {
    fetchingData = true;
    notifyListeners();

    try {
      _reliefs = await _repository.getTaxReliefs(token);
      print("✅ Fetched ${_reliefs.length} tax relief items.");
    } catch (e) {
      print("🚨 Failed to load tax reliefs: $e");
      _reliefs = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }
  Future<void> fetchTaxReliefType(String token) async {
    fetchingData = true;
    notifyListeners();

    try {
      _reliefsTypes = await _repository.getTaxReliefs(token);
      print("✅ Fetched ${_reliefsTypes.length} tax relief items.");
    } catch (e) {
      print("🚨 Failed to load tax reliefs: $e");
      _reliefsTypes = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
    print("🧹 TaxReliefViewModel disposed.");
  }
}