import 'dart:convert';
import 'dart:typed_data'; // Correct import for Uint8List
import 'package:flutter/material.dart';

// get item full details
class compareItems {
  final int itemcode;
  final String itemname;
  final String? unit;
  final String? brand;
  final String? description;
  final String? itemgroup;
  final String? itemcategory;
  final Uint8List? itemimage;
  final int premiseid;
  final double? price;
  final String? premisename;
  final String? address;
  final String? premisetype;
  final String? state;
  final String? district;

  compareItems({
    required this.itemcode,
    required this.itemname,
    required this.unit,
    required this.brand,
    required this.description,
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

  factory compareItems.fromJson(Map<String, dynamic> json) {
    return compareItems(
      itemcode: int.parse(json['itemcode'].toString()),
      itemname: json['itemname'],
      unit: json['unit'],
      brand: json['brand'],
      description: json['description'],
      itemgroup: json['itemgroup'],
      itemcategory: json['itemcategory'],
      itemimage:
      json['itemimage'] != null
          ? base64Decode(json['itemimage']) // Decode Base64 to Uint8List
          : null,
      premiseid: int.parse(json['premiseid'].toString()),
      price: double.parse(json['price'].toString()),
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
      'brand': brand,
      'itemgroup': itemgroup,
      'itemcategory': itemcategory,
      'image':
      itemimage, // Consider converting to base64 if sending as JSON string
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
