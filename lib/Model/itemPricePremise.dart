import 'dart:convert';
import 'dart:typed_data'; // Correct import for Uint8List
import 'package:flutter/material.dart';

// get item full details
class itemPrice {
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

  itemPrice({
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

  factory itemPrice.fromJson(Map<String, dynamic> json) {
    return itemPrice(
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

// for item to be search in search bar
class itemSearch {
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

  itemSearch({
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
  factory itemSearch.fromJson(Map<String, dynamic> json) {
    return itemSearch(
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
  }  Map<String, dynamic> toJson() {
    return {
      'itemcode': itemcode,
      'itemname': itemname,
      'unit': unit,
      'brand': brand,
      'description': description,
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

// to show users best deals
class itemBestDeals {
  final int itemcode;
  final String itemname;
  final String? unit;
  final String? brand;
  final Uint8List? itemimage;
  final double? price;
  final int? premiseid;
  final String? premisename;
  final String? address;
  final String? state;
  final String? district;
  final double? latitude;
  final double? longitude;

  itemBestDeals({
    required this.itemcode,
    required this.itemname,
    required this.unit,
    required this.brand,
    required this.itemimage,
    required this.price,
    this.premiseid,
    this.premisename,
    this.address,
    this.state,
    this.district,
    this.latitude,
    this.longitude,
  });

  factory itemBestDeals.fromJson(Map<String, dynamic> json) {
    // grab the raw price value
    final rawPrice = json['price'];
    // convert it into a double (or null if it can't be parsed)
    double? parsedPrice;
    if (rawPrice != null) {
      if (rawPrice is num) {
        parsedPrice = rawPrice.toDouble();
      } else {
        // fall back to parsing from string
        parsedPrice = double.tryParse(rawPrice.toString());
      }
    }

    return itemBestDeals(
      itemcode: int.parse(json['itemcode'].toString()),
      itemname: json['itemname'] as String,
      unit: json['unit'],
      brand: json['brand'],
      itemimage:
          json['itemimage'] != null ? base64Decode(json['itemimage']) : null,
      price: parsedPrice,
      premisename: json['premisename'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemcode': itemcode,
      'itemname': itemname,
      'unit': unit,
      'brand': brand,
      'image':
          itemimage, // Consider converting to base64 if sending as JSON string
      'price': price,
      'premisename': premisename,
      'address': address,
    };
  }
}

// to view store location around users
class storeLocation {
  final int? premiseid;
  final String? premisename;
  final String? premisetype;
  final String? address;
  final String? district;
  final String? state;
  final double? latitude;
  final double? longitude;
  final Uint8List? image;
  storeLocation({
    required this.premiseid,
    this.premisename,
    this.premisetype,
    this.address,
    this.district,
    this.state,
    this.latitude,
    this.longitude,
    this.image
  });

  factory storeLocation.fromJSON(Map<String, dynamic> json) {
    return storeLocation(
      premiseid: int.parse(json['premiseid'].toString()),
      premisename: json['premisename'],
      premisetype: json['premisetype'],
      address: json['address'],
      district: json['district'],
      state: json['state'],
      longitude: double.parse(json['longitude'].toString()),
      latitude: double.parse(json['latitude'].toString()),
      image: json['image'] != null ? base64Decode(json['image']) : null,
    );
  }
}

