import 'package:flutter/material.dart';
import '../../Model/taxRelief.dart';
import 'taxRelief_repository.dart';

class TaxReliefViewModel extends ChangeNotifier {
  final TaxReliefRepository repository = TaxReliefRepository();

  List<TotalCanClaim> _totalItemAmount = [];
  List<TotalCanClaim> get totalItemAmount => _totalItemAmount;

  List<TotalEligibleClaim> _totalEligibleClaim = [];
  List<TotalEligibleClaim> get totalEligibleClaim => _totalEligibleClaim;

  List<TaxReliefCategory> _taxReliefCategory = [];
  List<TaxReliefCategory> get taxReliefCategory => _taxReliefCategory;

  List<TaxReliefItem> _taxReliefItem = [];
  List<TaxReliefItem> get taxReliefItem => _taxReliefItem;

  bool fetchingData = false;

  Future<void> fetchTotalCanClaim(String token) async {
    fetchingData = true;
    notifyListeners();
    try {
      _totalItemAmount = await repository.getTotalCanClaim(token);
    } catch (e) {
      print('Failed to get total amount of relief: $e');
      _totalItemAmount = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchTotalEligibleClaim(int userid, String token) async {
    fetchingData = true;
    notifyListeners();
    try {
      _totalEligibleClaim = await repository.getTotalEligibleClaim(
        userid,
        token,
      );
    } catch (e) {
      print('Failed to get totall eligible amount: $e');
      _totalEligibleClaim = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchTaxReliefCategory(int userid, String token) async {
    fetchingData = true;
    notifyListeners();
    try {
      _taxReliefCategory = await repository.getTaxReliefCategory(userid, token);
    } catch (e, stacktrace) {
      print('❌ Failed to get tax relief category: $e');
      print('📍 Stacktrace: $stacktrace');
      _taxReliefCategory = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchTaxReliefItem(int userid, int categoryid, String token) async{
    fetchingData = true;
    notifyListeners();
    try {
      _taxReliefItem = await repository.getTaxReliefItem(userid, categoryid, token);
    } catch (e, stacktrace) {
      print('❌ Failed to get tax relief item: $e');
      print('📍 Stacktrace: $stacktrace');
      _taxReliefItem = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    repository.dispose();
    super.dispose();
    print("🧹 TaxReliefViewModel disposed.");
  }
}
