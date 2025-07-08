
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddItemCart{
  final int userid;
  final int itemcode;
  final String? brand;
  final String? unit;
  final int quantity;

  AddItemCart({
    required this.userid,
    required this.itemcode,
    required this.brand,
    required this.unit,
    required this.quantity
  });

  factory AddItemCart.fromJson(Map<String,dynamic> json){
    return AddItemCart(
        userid: int.parse(json['userid'].toString()),
        itemcode: int.parse(json['itemcode'].toString()),
        unit: json['unit'],
        brand: json['brand'],
        quantity: int.parse(json['quantity'].toString())
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'userid': userid,
      'itemcode': itemcode,
      'unit': unit,
      'brand': brand,
      'quantity': quantity
    };
  }
}

class ViewItemCart{
  final int cartId;
  final int itemcode;
  final String? itemname;
  final String? brand;
  final String? unit;
  final int quantity;

  ViewItemCart({
    required this.cartId,
    required this.itemname,
    required this.itemcode,
    required this.brand,
    required this.unit,
    required this.quantity
  });

  factory ViewItemCart.fromJson(Map<String,dynamic> json){
    return ViewItemCart(
        cartId: int.parse(json['cartid'].toString()),
        itemname: json['itemname'],
        itemcode: int.parse(json['itemcode'].toString()),
        unit: json['unit'],
        brand: json['brand'],
        quantity: int.parse(json['quantity'].toString())
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'cartid': cartId,
      'itemname': itemname,
      'itemcode': itemcode,
      'unit': unit,
      'brand': brand,
      'quantity': quantity
    };
  }
}

class UpdateItemCartQty{
  final int userid;
  final int itemcode;
  final int quantity;

  UpdateItemCartQty({
    required this.userid,
    required this.itemcode,
    required this.quantity
});

  factory UpdateItemCartQty.fromJson(Map<String,dynamic> json){
    return UpdateItemCartQty(
        userid: int.parse(json['userid'].toString()),
        itemcode: int.parse(json['itemcode'].toString()),
        quantity: int.parse(json['quantity'].toString())
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'itemcode': itemcode,
      'quantity' : quantity
    };
  }
}

class RemoveItemInCart{
  final int userid;
  final int itemcode;

  RemoveItemInCart({
    required this.userid,
    required this.itemcode,
  });

  factory RemoveItemInCart.fromJson(Map<String,dynamic> json){
    return RemoveItemInCart(
        userid: int.parse(json['userid'].toString()),
        itemcode: int.parse(json['itemcode'].toString()),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'userid': userid,
      'itemcode': itemcode,
    };
  }
}

class DeleteCart {
  final int cart_item_id;

  DeleteCart({
    required this.cart_item_id,
  });

  // Construct a DeleteExpense instance from JSON
  factory DeleteCart.fromJson(Map<String, dynamic> json) {
    return DeleteCart(
      cart_item_id: int.parse(json['cart_item_id'].toString()),
    );
  }

  // Convert DeleteItemCart object to a Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'cart_item_id': cart_item_id,
    };
  }
}

// get best deals for items in cart
/*
class CompareCart{
  final int itemcode;
  final int quantity;
  final LatLng location;
  final double radius;


  CompareCart({
    required this.itemcode,
    required this.quantity,
    required this.location,
    required this.radius
});
  factory CompareCart.fromJson(Map<String,dynamic> json){
    return CompareCart(
      itemcode: int.parse(json['itemcode'].toString()),
      quantity: int.parse(json['quantity'].toString()),
        location: LatLng(
          double.parse(json['latitude'].toString()),
          double.parse(json['longitude'].toString()),
        ),
      radius: double.parse(json['radius'])
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'itemcode': itemcode,
      'quantity': quantity,
      'location': location,
      'radius': radius
    };
  }

}

 */

class CompareCart {
  final int premiseid;
  final String premisename;
  final double distance_km;
  final int matchedItems;
  final String matchedItemsName;
  final double totalCost;

  CompareCart({
    required this.premiseid,
    required this.premisename,
    required this.distance_km,
    required this.matchedItems,
    required this.matchedItemsName,
    required this.totalCost,
  });

  factory CompareCart.fromJson(Map<String, dynamic> json) {
    return CompareCart(
      premiseid: int.parse(json['premiseid'].toString()),
      premisename: json['premisename'],
      distance_km: double.parse(json['distance_km'].toString()),
      matchedItems: int.parse(json['matched_items'].toString()),
      matchedItemsName: json['matched_item_names'],
      totalCost: double.parse(json['total_cost'].toString()),
    );
  }
}


