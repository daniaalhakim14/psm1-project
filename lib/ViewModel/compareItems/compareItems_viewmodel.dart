
import 'package:flutter/cupertino.dart';
import 'package:fyp/Model/compareItems.dart';
import 'package:fyp/ViewModel/compareItems/compareItems_repository.dart';
import 'package:fyp/ViewModel/itemPricePremise/itemPrice_repository.dart';

import '../../Model/itemPricePremise.dart';

class compareItems_viewmodel extends ChangeNotifier{
  final compareItemsRepository = compareItems_repositoryClass();
  bool fetchingData = false;

  List<itemPrice> _itemprice = [];
  List<itemPrice> get itemprice => _itemprice;


  Future<void> fetchItemPriceDetails(int itemcode, double lat, double lng, double radius, String storeType, String priceRange,String itemGroup) async {
    fetchingData = true;
    notifyListeners();
    try{
      _itemprice = await compareItemsRepository.getItemPriceDetails(itemcode, lat, lng, radius, storeType, priceRange, itemGroup);
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