
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

  Future<List<itemPrice>> getBestDeals() async{
    final response = await _service.fetchBestDeals();
    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      //print('Decoded search item: $data');
      return List<itemPrice>.from(
          data.map((x) => itemPrice.fromJson(x))
      );
    }else{
      print('API Error: ${response.body}');
      throw Exception('Failed to load best deals');
    }
  }

}