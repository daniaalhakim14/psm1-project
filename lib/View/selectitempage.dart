import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:fyp/Model/cart.dart';
import 'package:fyp/Model/itemPricePremise.dart';
import 'package:fyp/View/itemcartpage.dart';
import 'package:fyp/ViewModel/cart/cart_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../ViewModel/itemPricePremise/itemPrice_viewmodel.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import 'compareitempage.dart';

class selectitempage extends StatefulWidget {
  final int? premiseid;
  final int? itemcode;
  final String? itemname;
  final String? searchQuery;
  final LatLng? currentPosition;
  final double? tempDistanceRadius;
  final String? tempStoreType;
  final String? tempPriceRange;
  final String? tempItemGroup;
  const selectitempage({
    super.key,
    required this.premiseid,
    required this.itemcode,
    required this.itemname,
    required this.searchQuery,
    required this.currentPosition,
    required this.tempDistanceRadius,
    required this.tempStoreType,
    required this.tempPriceRange,
    required this.tempItemGroup,
  });

  @override
  State<selectitempage> createState() => _selectitempageState();
}

class _selectitempageState extends State<selectitempage> {
  late List<itemPrice> items;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<itemPrice_viewmodel>(
        context,
        listen: false,
      );

      print('Debug: itemcode = ${widget.itemcode}');
      print('Debug: premisid = ${widget.premiseid}');
      print('Debug: searchQuery = ${widget.searchQuery}');

      // Check if we have specific item details (from ListTile tap)
      if (widget.itemcode != null &&
          widget.premiseid != null &&
          widget.searchQuery != null &&
          widget.currentPosition != null &&
          widget.tempDistanceRadius != null &&
          widget.tempStoreType != null &&
          widget.tempPriceRange != null &&
          widget.tempItemGroup != null) {

        print('Debug: Calling fetchSelectedItemDetail');
        // Fetch specific item details
        viewModel.fetchSelectedItemDetail(
          widget.premiseid!,
          widget.itemcode!,
          widget.searchQuery!,
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
          widget.tempDistanceRadius!,
          widget.tempStoreType!,
          widget.tempPriceRange!,
          widget.tempItemGroup!,
        );
      }
      // Check if we have search query only (from onSubmitted)
      else if (widget.searchQuery != null &&
          widget.currentPosition != null &&
          widget.tempDistanceRadius != null &&
          widget.tempStoreType != null &&
          widget.tempPriceRange != null &&
          widget.tempItemGroup != null) {

        print('Debug: Calling fetchItemSearch');
        // Fetch items based on search query only
        viewModel.fetchItemSearch(
          widget.searchQuery!,
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
          widget.tempDistanceRadius!,
          widget.tempStoreType!,
          widget.tempPriceRange!,
          widget.tempItemGroup!,
        );
      } else {
        print('Debug: No conditions met - this might be the issue');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final viewModel = Provider.of<itemPrice_viewmodel>(context);

    List<dynamic> items;
    if(widget.itemcode != null && widget.premiseid != null ){
      // Coming from ListTile tap - use itemprice
      items = viewModel.itemprice;
    }else{
      // Coming from onSubmitted - use itemsearch
      items = viewModel.itemsearch;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Item',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            // Cart Button
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => itemcart(
                        currentPosition: (widget.currentPosition),
                        tempDistanceRadius: widget.tempDistanceRadius,
                        tempStoreType: widget.tempStoreType,
                        tempPriceRange: widget.tempPriceRange,
                        tempItemGroup: widget.tempItemGroup,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.shopping_cart_outlined, size: 30),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF5A7BE7),
        automaticallyImplyLeading: true,
      ),
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 5,),
          if (viewModel.fetchingData)
            const Center(child: CircularProgressIndicator())
          else Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Center(
                  child: ItemCard(
                    itemName: item.itemname,
                    itemBrand: item.brand ?? 'NOT AVAILABLE',
                    itemUnit: item.unit ?? '',
                    itemDescription: item.description,
                    itemPrice: item.price ?? 0.0,
                    onCompare: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => compareitem(
                            itemcode: item.itemcode,
                            itemname: item.itemname,
                            currentPosition: (widget.currentPosition!),
                            tempDistanceRadius: widget.tempDistanceRadius!,
                            tempStoreType: widget.tempStoreType!,
                            tempPriceRange: widget.tempPriceRange!,
                            tempItemGroup: widget.tempItemGroup,
                          ),
                        ),
                      );
                    },
                    onCart: () async {
                      final userId = Provider.of<signUpnLogin_viewmodel>(context, listen: false,).userInfo!.id;
                      final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false,).authToken;
                      final viewModel = Provider.of<cartViewModel>(context,listen: false);

                      AddItemCart itemCartData = AddItemCart(
                        userid: userId,
                        itemcode: item.itemcode,
                        brand: item.brand,
                          unit: item.unit,
                        quantity: 1

                      );
                      try{
                        if(token !=null){
                          await viewModel.addItemCart(itemCartData, token);

                          bool dismissedByTimer = true;

                          await showDialog(
                            context: context,
                            barrierDismissible:
                            false, // Prevent dismiss by tapping outside
                            builder: (BuildContext context) {
                              // Start a delayed close
                              Future.delayed(Duration(seconds: 3), () {
                                if (dismissedByTimer && Navigator.canPop(context)) {
                                  Navigator.of(context).pop(); // Auto close after 3s
                                }
                              });

                              return AlertDialog(
                                title: const Text('Success'),
                                content: const Text('Item added to cart successfully!'),
                                actions: [
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      dismissedByTimer =
                                      false; // User pressed manually
                                      Navigator.of(context).pop(); // Close dialog
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }catch(e){
                        print('Failed to add item to cart: $e');
                      }
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }
}
bool _isPressed = false;
class ItemCard extends StatelessWidget {
  final String itemName;
  final String itemBrand;
  final String itemUnit;
  final double itemPrice;
  final String itemDescription;
  final VoidCallback onCompare;
  final VoidCallback onCart;

  const ItemCard({
    super.key,
    required this.itemName,
    required this.itemBrand,
    required this.itemUnit,
    required this.itemPrice,
    required this.itemDescription,
    required this.onCompare,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Container(
        width: screenWidth * 0.98,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFF5A7BE7), width: 2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Details Table
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {0: IntrinsicColumnWidth()},
                children: [
                  TableRow(children: [
                    Text('Name: $itemName', style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  TableRow(children: [
                    Text('Brand: $itemBrand', style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  TableRow(children: [
                    Text('Unit: $itemUnit', style: TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  TableRow(children: [
                    Text(
                      'Description: $itemDescription',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
                  TableRow(children: [
                    Text(
                      'Price: RM ${itemPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A7BE7), fontSize: 18),
                    ),
                  ]),
                ],
              ),
              SizedBox(height: 12),

              // Buttons: Compare + Add
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onCompare,
                    icon: Icon(Icons.compare_arrows, size: 28),
                    label: Text('Compare', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5A7BE7),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: onCart,
                    icon: Icon(Icons.shopping_cart_outlined, size: 28),
                    label: Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

