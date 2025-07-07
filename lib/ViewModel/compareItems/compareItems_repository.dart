
import 'dart:convert';

import 'package:fyp/Model/compareItems.dart';
import 'package:fyp/ViewModel/compareItems/compareItems_callapi.dart';
import '../../Model/itemPricePremise.dart';

class compareItems_repositoryClass{
  final compareItems_callapi _service = compareItems_callapi();

  Future<List<itemPrice>> getItemPriceDetails(int itemcode, double lat, double lng, double radius, String storeType, String priceRange,String itemGroup) async{
    final response = await _service.fetchItemPricesDetails(itemcode, lat, lng, radius, storeType, priceRange, itemGroup);
    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      // print('Decoded item prices details: $data');
      return List<itemPrice>.from(
          data.map((x)=> itemPrice.fromJson(x))
      );
    }else{
      print('API Error: ${response.body}');
      throw Exception('Failed to load item with the same itemcode');
    }
  }
}