
import 'dart:convert';

import 'package:fyp/ViewModel/itemPricePremise/itemPrice_callapi.dart';

import '../../Model/itemPricePremise.dart';

class itemPrice_repositoryClass{
  final itemPrice_callapi _service = itemPrice_callapi();

  Future<List<itemPrice>> getItemPrice() async{
    final response = await _service.fetchItemPrice();
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      return List<itemPrice>.from(
        data.map((x) => itemPrice.fromJson(x))
      );
    }else{
      print('API Error: ${response.body}');
      throw Exception('Failed to load item price');
    }
  }

  Future<List<itemSearch>> getItemSearch(String searchTerm) async{
    final response = await _service.fetchItemSearch(searchTerm);
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      //print('Decoded search item: $data');
      return List<itemSearch>.from(
          data.map((x) => itemSearch.fromJson(x))
      );
    }else{
      print('API Error: ${response.body}');
      throw Exception('Failed to load item Search');
    }
  }

  Future<List<itemBestDeals>> getBestDeals() async{
    final response = await _service.fetchBestDeals();
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      // print('Decoded best deals item: $data');
      return List<itemBestDeals>.from(
          data.map((x) => itemBestDeals.fromJson(x))
      );
    }else{
      print('API Error: ${response.body}');
      throw Exception('Failed to load best deals');
    }
  }

  Future<List<storeLocation>> getStoreLocation() async{
    final response = await _service.fetchStoreLocation();
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      print('Decoded premise location information item: $data');
      return List<storeLocation>.from(
          data.map((x) => storeLocation.fromJSON(x))
      );
    }else{
      print('API Error: ${response.body}');
      throw Exception('Failed to load best deals');
    }

  }

}