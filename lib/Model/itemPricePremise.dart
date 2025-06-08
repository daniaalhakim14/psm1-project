import 'dart:convert';
import 'dart:typed_data'; // Correct import for Uint8List
import 'package:flutter/material.dart';

// get item full details
class itemPrice {
  final int itemcode;
  final String itemname;
  final String unit;
  final String itemgroup;
  final String itemcategory;
  final Uint8List? itemimage;
  final int premiseid;
  final double price;
  final String premisename;
  final String address;
  final String premisetype;
  final String state;
  final String district;

  itemPrice({
    required this.itemcode,
    required this.itemname,
    required this.unit,
    required this.itemgroup,
    required this.itemcategory,
    required this.itemimage,
    required this.premiseid,
    required this.price,
    required this.premisename,
    required this.address,
    required this.premisetype,
    required this.state,
    required this.district,
  });

  factory itemPrice.fromJson(Map<String, dynamic> json) {
    return itemPrice(
      itemcode: json['itemcode'],
      itemname: json['itemname'],
      unit: json['unit'],
      itemgroup: json['itemgroup'],
      itemcategory: json['itemcategory'],
      itemimage:
          json['itemimage'] != null
              ? base64Decode(json['itemimage']) // Decode Base64 to Uint8List
              : null,
      premiseid: json['premiseid'],
      price: (json['price'] as num).toDouble(),
      premisename: json['premisename'],
      address: json['address'],
      premisetype: json['premisetype'],
      state: json['state'],
      district: json['district'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemcode': itemcode,
      'itemname': itemname,
      'unit': unit,
      'itemgroup': itemgroup,
      'itemcategory': itemcategory,
      'image': itemimage, // Consider converting to base64 if sending as JSON string
      'premiseid': premiseid,
      'price': price,
      'premisename': premisename,
      'address': address,
      'premisetype': premisetype,
      'state': state,
      'district': district,
    };
  }
}

// for item to be search in search bar
class itemSearch{
  final int itemcode;
  final String itemname;
  final Uint8List? image;

  itemSearch({
    required this.itemcode,
    required this.itemname,
    required this.image,
});
  factory itemSearch.fromJson(Map<String, dynamic> json) {
    return itemSearch(
        itemcode:int.parse(json['itemcode'].toString()),
        itemname: json['itemname'],
        image:
        json['itemimage'] != null
            ? base64Decode(json['itemimage']) // Decode Base64 to Uint8List
            : null
    );
  }
}
