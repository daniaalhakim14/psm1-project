import 'package:flutter/material.dart';
import '../../Model/taxRelief.dart';
import 'taxRelief_repository.dart';

class TaxReliefViewModel extends ChangeNotifier {
  final TaxReliefRepository repository = TaxReliefRepository();

  List<TotalCanClaim> _totalReliefList = [];
  List<TotalCanClaim> get totalReliefList => _totalReliefList;
  List<TotalEligibleClaim> _totalEligibleClaim = [];
  List<TotalEligibleClaim> get totalEligibleClaim => _totalEligibleClaim;

  List<TaxReliefCategory> _taxReliefCategory = [];
  List<TaxReliefCategory> get taxReliefCategory => _taxReliefCategory;


  List<ReliefTypeInfo>  _reliefTypeInfo = [];
  List<ReliefTypeInfo> get reliefTypeInfo => _reliefTypeInfo;

  List<ReliefCategoryInfo> _reliefCategoryInfo = [];
  List<ReliefCategoryInfo> get reliefCategoryInfo => _reliefCategoryInfo;

  bool fetchingData = false;


  Future<void> fetchTotalCanClaim(String token) async {
    fetchingData = true;
    notifyListeners();
    try {
      _totalReliefList = await repository.getTotalCanClaim(token);
    } catch (e) {
      print('Failed to get total amount of relief: $e');
      _totalReliefList = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchTotalEligibleClaim(int userid, String token) async{
    fetchingData = true;
    notifyListeners();
    try{
      _totalEligibleClaim = await repository.getTotalEligibleClaim(userid, token);
    } catch(e){
      print('Failed to get totall eligible amount: $e');
      _totalEligibleClaim = [];
    }finally{
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

  Future<void> fetchReliefTypeInfo(int categoryid, String token) async {
    fetchingData = true;
    notifyListeners();
    try {
      _reliefTypeInfo = await repository.getReliefTypeInfo(categoryid, token);
    } catch (e, stacktrace) {
      print('❌ Failed to get tax relief: $e');
      print('📍 Stacktrace: $stacktrace');
      _reliefTypeInfo = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }


  Future<void> fetchReliefCategoryInfo(int categoryid, String token) async {
    fetchingData = true;
    notifyListeners();
    try {
      _reliefCategoryInfo = await repository.getReliefCategoryInfo(categoryid, token);
    } catch (e, stacktrace) {
      print('❌ Failed to get tax relief: $e');
      print('📍 Stacktrace: $stacktrace');
      _reliefCategoryInfo = [];

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