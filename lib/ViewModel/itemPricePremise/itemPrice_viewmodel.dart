
import 'package:flutter/cupertino.dart';
import 'package:fyp/ViewModel/itemPricePremise/itemPrice_repository.dart';

import '../../Model/itemPricePremise.dart';

class itemPrice_viewmodel extends ChangeNotifier{
  final itemPriceRepository = itemPrice_repositoryClass();
  final itemPrice_repositoryClass _repository = itemPrice_repositoryClass();
  bool fetchingData = false;

  List<itemPrice> _itemprice = [];
  List<itemPrice> get itemprice => _itemprice;
  List<itemSearch> _itemsearch = [];
  List<itemSearch> get itemsearch => _itemsearch;
  // use the same model class as itemPrice
  List<itemPrice> _bestdeals = [];
  List<itemPrice> get bestdeals => _bestdeals;

  Future<void> fetchItemPrice() async{
    fetchingData = true;
    notifyListeners();

    try{
      _itemprice = await itemPriceRepository.getItemPrice();
    } catch(e){
      print('Failed to load item price: $e');
      _itemprice = [];
    } finally{
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchItemSearch(String searchTerm) async{
    fetchingData = true;
    notifyListeners();
    try{
      _itemsearch = await itemPriceRepository.getItemSearch(searchTerm);
      notifyListeners(); // <- make sure this is called AFTER updating _itemsearch
    } catch(e){
      print('Failed to load item price: $e');
      _itemsearch = [];
    } finally{
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchBestDeals() async{
    fetchingData = true;
    notifyListeners();
    try{
      _bestdeals = await itemPriceRepository.getBestDeals();
    } catch(e){
      print('Failed to load item price: $e');
      _bestdeals = [];
    } finally{
      fetchingData = false;
      notifyListeners();
    }
  }
}