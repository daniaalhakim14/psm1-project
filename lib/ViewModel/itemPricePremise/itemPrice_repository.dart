import 'dart:convert';

import 'package:fyp/ViewModel/itemPricePremise/itemPrice_callapi.dart';

import '../../Model/itemPricePremise.dart';

class itemPrice_repositoryClass {
  final itemPrice_callapi _service = itemPrice_callapi();

  /*
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
  }*/

  Future<List<itemPrice>> getItemPrice() async {
    final response = await _service.fetchItemPrice();
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<itemPrice>.from(data.map((x) => itemPrice.fromJson(x)));
    } else {
      print('API Error: ${response.body}');
      throw Exception('Failed to load item price');
    }
  }

  Future<List<itemSearch>> getItemSearch(
    String searchTerm,
    double lat,
    double lng,
    double radius,
    String storeType,
    String priceRange,
    String itemGroup,
  ) async {
    final response = await _service.fetchItemSearch(
      searchTerm,
      lat,
      lng,
      radius,
      storeType,
      priceRange,
      itemGroup,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Decoded search item: $data');
      return List<itemSearch>.from(data.map((x) => itemSearch.fromJson(x)));
    } else {
      print('API Error: ${response.body}');

      // Check if the error is specifically about no stores found
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['error'] != null &&
            errorData['error'].toString().contains('No stores found')) {
          print(
            'No stores found within radius for search - returning empty list',
          );
          return []; // Return empty list instead of throwing exception
        }
      } catch (e) {
        // If we can't parse the error, continue with the original error handling
      }

      throw Exception('Failed to load item Search');
    }
  }

  Future<List<itemBestDeals>> getBestDeals(
    double lat,
    double lng,
    double radius,
    String storeType,
  ) async {
    final response = await _service.fetchBestDeals(lat, lng, radius, storeType);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('🔍 Decoded best deals response: $data');

      // Let's also print individual items to see their structure
      if (data is List && data.isNotEmpty) {
        print('📦 First item structure: ${data[0]}');
        print('🗺️ Latitude in first item: ${data[0]['latitude']}');
        print('🗺️ Longitude in first item: ${data[0]['longitude']}');
      }

      return List<itemBestDeals>.from(
        data.map((x) => itemBestDeals.fromJson(x)),
      );
    } else {
      print('API Error: ${response.body}');

      // Check if the error is specifically about no stores found
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['error'] != null &&
            errorData['error'].toString().contains('No stores found')) {
          print('No stores found within radius - returning empty list');
          return []; // Return empty list instead of throwing exception
        }
      } catch (e) {
        // If we can't parse the error, continue with the original error handling
      }

      throw Exception('Failed to load best deals');
    }
  }

  Future<List<storeLocation>> getStoreLocation(
    double lat,
    double lng,
    double radius,
    String storeType,
  ) async {
    final response = await _service.fetchStoreLocation(
      lat,
      lng,
      radius,
      storeType,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //print('Decoded premise location information item: $data');
      return List<storeLocation>.from(
        data.map((x) => storeLocation.fromJSON(x)),
      );
    } else {
      print('API Error: ${response.body}');

      // Check if the error is specifically about no stores found
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['error'] != null &&
            errorData['error'].toString().contains('No stores found')) {
          print('No stores found within radius - returning empty list');
          return []; // Return empty list instead of throwing exception
        }
      } catch (e) {
        // If we can't parse the error, continue with the original error handling
      }

      throw Exception('Failed to load store locations');
    }
  }

  Future<List<itemPrice>> getSelectedItemDetail(
    int premiseid,
    int itemcode,
    String searchTerm,
    double lat,
    double lng,
    double radius,
    String storeType,
    String priceRange,
    String itemGroup,
  ) async {
    final response = await _service.fetchSelectedItemDetail(
      premiseid,
      itemcode,
      searchTerm,
      lat,
      lng,
      radius,
      storeType,
      priceRange,
      itemGroup,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //print('Decoded selected item details : $data');
      return List<itemPrice>.from(data.map((x) => itemPrice.fromJson(x)));
    } else {
      print('API Error: ${response.body}');
      throw Exception('Failed to load selected item');
    }
  }

  Future<List<itemPrice>> getItemPriceDetails(
    int itemcode,
    double lat,
    double lng,
    double radius,
    String storeType,
    String priceRange,
    String itemGroup,
  ) async {
    final response = await _service.fetchItemPricesDetails(
      itemcode,
      lat,
      lng,
      radius,
      storeType,
      priceRange,
      itemGroup,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print('Decoded item prices details: $data');
      return List<itemPrice>.from(data.map((x) => itemPrice.fromJson(x)));
    } else {
      print('API Error: ${response.body}');
      throw Exception('Failed to load item with the same itemcode');
    }
  }
}
