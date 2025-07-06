import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:fyp/Model/itemPricePremise.dart';
import 'package:fyp/View/itemcartpage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../ViewModel/itemPricePremise/itemPrice_viewmodel.dart';
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
        title: Text('Select Item',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFF5A7BE7),
        automaticallyImplyLeading: true,
      ),
      body:
      Column(
        children: [
          SizedBox(height: 5,),
          viewModel.fetchingData
              ? Center(child: CircularProgressIndicator())
              : Expanded(
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
                          builder: (context) => compareitem(),
                        ),
                      );
                    },
                    onCart: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => itemcart()),
                      );
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: Container(
        height: screenHeight * 0.25,
        width: screenWidth * 0.98,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFF5A7BE7), width: 2.0),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  /*
                  // Image placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage('assets/Icons/no_picture.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                   */
                  // Item info
                  SizedBox(
                    height: screenHeight * 0.1,
                    width: screenWidth * 0.78,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        columnWidths: {0: IntrinsicColumnWidth()},
                        children: [
                          TableRow(
                            children: [
                              Text(
                                'Name: $itemName',
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Text(
                                'Brand: $itemBrand',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Text(
                                'Unit: $itemUnit',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Text(
                                'Description: $itemDescription',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Text(
                                'Price: RM ${itemPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF5A7BE7),fontSize: 18),
                              )
                            ]
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onCompare,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Compare button
                          SizedBox(
                              width: 140,
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: Duration(
                                        milliseconds: 800,
                                      ), // 🔧 Adjust timer here
                                      pageBuilder:
                                          (context, animation, secondaryAnimation) =>
                                          compareitem(),
                                      transitionsBuilder: (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                          ) {
                                        const begin = Offset(
                                          1.0,
                                          0.0,
                                        ); // Start off-screen to the right
                                        const end = Offset.zero;
                                        const curve = Curves.ease;

                                        var tween = Tween(
                                          begin: begin,
                                          end: end,
                                        ).chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                icon: Icon(Icons.compare_arrows, size: 35,),
                                //icon: Image.asset('assets/Icons/compare_icon.png', width: 35, height: 35,),
                                label: Text('Compare',
                                    style:TextStyle(fontWeight:FontWeight.bold, fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF5A7BE7),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Cart button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: onCart,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 45,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.shopping_cart_outlined, size: 30),
                              label: Text('Add',
                                  style: TextStyle(fontWeight:FontWeight.bold, fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF9800),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
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
