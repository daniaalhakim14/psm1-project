import 'package:http/http.dart' as http;

import '../../configure_api.dart';

class itemPrice_callapi {
  final http.Client _httpClient = http.Client();

  /*
  Future<http.Response> fetchItemPrice() async {
    String endpoint = '/itemPrice';
    String url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(Uri.parse(url));
  }*/

  Future<http.Response> fetchItemPrice() async {
    String endpoint = '/itemPrice';
    String url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(Uri.parse(url));
  }

  Future<http.Response> fetchItemSearch(String searchTerm,double lat, double lng, double radius, String storeType, String priceRange,String itemGroup) async {
    //String endpoint = '/itemSearch?searchTerm=$searchTerm';
    final encodedStoreType = Uri.encodeQueryComponent(storeType);
    final encodedPriceRange = Uri.encodeQueryComponent(priceRange);
    final encodedItemGroup = Uri.encodeQueryComponent(itemGroup);

    String endpoint = '/itemPrice/itemSearch?searchTerm=$searchTerm&lat=$lat&lng=$lng&radius=$radius&type=$encodedStoreType&priceRange=$encodedPriceRange&itemGroup$encodedItemGroup';
    String url = '${AppConfig.baseUrl}$endpoint';
    return await http.get(Uri.parse(url));
  }

  Future<http.Response> fetchBestDeals(double lat, double lng, double radius, String storeType) async {
    // Encode storeType to handle spaces/special characters in URL
    final encodedStoreType = Uri.encodeQueryComponent(storeType);
    String endpoint = '/itemPrice/bestDeals?lat=$lat&lng=$lng&radius=$radius&type=$encodedStoreType';
    String url = '${AppConfig.baseUrl}$endpoint';
    //print('bestdeals url: $url');
    return await _httpClient.get(Uri.parse(url));
  }

  Future<http.Response> fetchStoreLocation(double lat, double lng, double radius, String storeType) async{
    // Encode storeType to handle spaces/special characters in URL
    final encodedStoreType = Uri.encodeQueryComponent(storeType);
    String endpoint = '/itemPrice/storeLocation?lat=$lat&lng=$lng&radius=$radius&type=$encodedStoreType';
    String url = '${AppConfig.baseUrl}$endpoint';
    print('store location: $url');
    return await http.get(Uri.parse(url));
  }

  Future<http.Response> fetchSelectedItemDetail(int premiseid,int itemcode,String searchTerm,double lat, double lng, double radius, String storeType, String priceRange,String itemGroup) async{
    final encodedStoreType = Uri.encodeQueryComponent(storeType);
    final encodedPriceRange = Uri.encodeQueryComponent(priceRange);
    final encodedItemGroup = Uri.encodeQueryComponent(itemGroup);
    final encodedSearch = Uri.encodeComponent(searchTerm);
    String  endpoint ='/itemPrice/itemPrices?premiseid=$premiseid&itemcode=$itemcode&searchTerm=$encodedSearch&lat=$lat&lng=$lng&radius=$radius&type=$encodedStoreType&priceRange=$encodedPriceRange&itemGroup=$encodedItemGroup';
    String url = '${AppConfig.baseUrl}$endpoint';
    print('selected item url: $url');
    return await http.get(Uri.parse(url));
  }

}
