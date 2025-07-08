import 'package:fyp/Model/compareItems.dart';
import 'package:http/http.dart' as http;
import '../../configure_api.dart';

class compareItems_callapi {
  final http.Client _httpClient = http.Client();
  //to get item with the same itemcode
  Future<http.Response> fetchItemPricesDetails(int itemcode, double lat, double lng, double radius, String storeType, String priceRange,String itemGroup) async{
    final encodedStoreType = Uri.encodeQueryComponent(storeType);
    final encodedPriceRange = Uri.encodeQueryComponent(priceRange);
    final encodedItemGroup = Uri.encodeQueryComponent(itemGroup);

    String endpoint = '/itemPrice/itemPriceDetails/$itemcode?lat=$lat&lng=$lng&radius=$radius&type=$encodedStoreType&priceRange=$encodedPriceRange&itemGroup=$encodedItemGroup';
    String url = '${AppConfig.baseUrl}$endpoint';
    print('item price details: $url');
    return await _httpClient.get(Uri.parse(url));
  }

}