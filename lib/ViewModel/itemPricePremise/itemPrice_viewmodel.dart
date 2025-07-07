
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
  List<itemBestDeals> _bestdeals = [];
  List<itemBestDeals> get bestdeals => _bestdeals;
  List<storeLocation> _storelocation = [];
  List<storeLocation> get storelocation => _storelocation;


  /*
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
   */

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

  Future<void> fetchItemSearch(String searchTerm,double lat, double lng, double radius, String storeType, String priceRange,String itemGroup) async{
    fetchingData = true;
    notifyListeners();
    try{
      _itemsearch = await itemPriceRepository.getItemSearch(searchTerm,lat, lng, radius, storeType,priceRange,itemGroup);
      notifyListeners(); // <- make sure this is called AFTER updating _itemsearch
    } catch(e){
      print('Failed to load item price: $e');
      _itemsearch = [];
    } finally{
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchBestDeals(double lat, double lng, double radius, String storeType) async {
    fetchingData = true;
    notifyListeners();
    try {
      bestdeals.clear();
      _bestdeals = await itemPriceRepository.getBestDeals(lat, lng, radius, storeType);
    } catch (e) {
      print('Failed to load item deals: $e');
      _bestdeals = [];
    } finally {
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchStoreLocation(double lat, double lng, double radius, String storeType) async{
    fetchingData = true;
    notifyListeners();
    try{
      _storelocation =await itemPriceRepository.getStoreLocation(lat,lng,radius,storeType);
    } catch(e){
      print('Failed to get premise location information: $e');
    }finally{
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchSelectedItemDetail(int premiseid,int itemcode,String searchTerm,double lat, double lng, double radius, String storeType, String priceRange,String itemGroup) async{
    fetchingData = true;
    notifyListeners();
    try{
      _itemprice = await itemPriceRepository.getSelectedItemDetail(premiseid, itemcode,searchTerm,lat, lng, radius, storeType,priceRange,itemGroup);
      // ✅ Print each item for debugging
      /*
      for (var item in _itemprice) {
        print('📦 Item: ${item.itemname}, Price: ${item.price}, Store: ${item.premisename}');
      }
       */
    } catch(e){
      print('Failed to get selected item: $e');
    }finally{
      fetchingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchItemPriceDetails(int itemcode, double lat, double lng, double radius, String storeType, String priceRange,String itemGroup) async {
    fetchingData = true;
    notifyListeners();
    try{
      _itemprice = await itemPriceRepository.getItemPriceDetails(itemcode, lat, lng, radius, storeType, priceRange, itemGroup);
    } catch(e){
      print('Failed to get item with same itemcode: $e');
    }finally{
      fetchingData = false;
      notifyListeners();
    }
        
  }
  // Set Default Distance Radius
  double distanceRadius = 10000.0;
  void setDistanceRadius(double radius) {
    distanceRadius = radius;
    notifyListeners(); // ensures UI updates
  }

  // Set Default store type.
  String storeType = '';
  void setStoreType(String type) {
    storeType = type;
    notifyListeners(); // ensures UI updates
  }

  // Set Default Price Range.
  String priceRange = '';
  void setPriceRange(String range) {
    storeType = range;
    notifyListeners(); // ensures UI updates
  }

  // Set Default Item Group.
  String itemGroup = '';
  void setItemGroup(String group) {
    storeType = group;
    notifyListeners(); // ensures UI updates
  }


}