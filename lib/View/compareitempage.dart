import 'package:flutter/material.dart';
import 'package:fyp/View/itemcartpage.dart';
import 'package:fyp/ViewModel/compareItems/compareItems_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../Model/cart.dart';
import '../ViewModel/cart/cart_viewmodel.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';

class compareitem extends StatefulWidget {
  final int? itemcode;
  final String? itemname;
  final LatLng? currentPosition;
  final double? tempDistanceRadius;
  final String? tempStoreType;
  final String? tempPriceRange;
  final String? tempItemGroup;
  const compareitem({
    super.key,
    required this.itemcode,
    required this.itemname,
    required this.currentPosition,
    required this.tempDistanceRadius,
    required this.tempStoreType,
    required this.tempPriceRange,
    required this.tempItemGroup,
  });

  @override
  State<compareitem> createState() => _compareitemState();
}

class _compareitemState extends State<compareitem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<compareItems_viewmodel>(
        context,
        listen: false,
      );
      if (widget.itemcode != null &&
          widget.itemname != null &&
          widget.currentPosition != null &&
          widget.tempDistanceRadius != null &&
          widget.tempStoreType != null &&
          widget.tempPriceRange != null &&
          widget.tempItemGroup != null) {
        viewModel.fetchItemPriceDetails(
          widget.itemcode!,
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
          widget.tempDistanceRadius!,
          widget.tempStoreType!,
          widget.tempPriceRange!,
          widget.tempItemGroup!,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final viewModel = Provider.of<compareItems_viewmodel>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Compare Items',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
      body: Column(
        children: [
          SizedBox(height: 5),
          viewModel.fetchingData
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                child: ListView.builder(
                  itemCount: viewModel.itemprice.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.itemprice[index];
                    return Center(
                      child: ItemCard(
                        itemcode: item.itemcode,
                        itemName: item.itemname,
                        itemBrand: item.brand ?? 'NOT AVAILABLE',
                        itemUnit: item.unit ?? '',
                        itemDescription: item.description ?? '',
                        itemPrice: item.price ?? 0.0,
                        storeName: item.premisename ?? 'NOT AVAILABLE',
                        currentPosition: widget.currentPosition!,
                        tempDistanceRadius: widget.tempDistanceRadius,
                        tempItemGroup: widget.tempItemGroup,
                        tempPriceRange: widget.tempPriceRange,
                        tempStoreType: widget.tempStoreType,
                        onAdd: () async {
                            final userId = Provider.of<signUpnLogin_viewmodel>(context, listen: false,).userInfo!.id;
                            final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false,).authToken;
                            final viewModel = Provider.of<cartViewModel>(context, listen: false,);
                            AddItemCart itemCartData =
                            AddItemCart(
                              userid: userId,
                              itemcode: item.itemcode,
                              brand: item.brand,
                              unit: item.unit,
                              quantity: 1,
                            );
                            print('userid: $userId, itemcode: ${item.itemcode}, brand: ${item.brand}, unit: ${item.unit}, quantity: 1');

                            try {
                              if (token != null) {
                                await viewModel.addItemCart(
                                  itemCartData,
                                  token,
                                );

                                bool dismissedByTimer = true;

                                await showDialog(
                                context: context,
                                barrierDismissible:
                                false, // Prevent dismiss by tapping outside
                                builder: (
                                    BuildContext context,
                                    ) {
                                  // Start a delayed close
                                  Future.delayed(
                                    Duration(seconds: 3),
                                        () {
                                      if (dismissedByTimer &&
                                          Navigator.canPop(
                                            context,
                                          )) {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Auto close after 3s
                                      }
                                    },
                                  );

                                  return AlertDialog(
                                    title: const Text(
                                      'Success',
                                    ),
                                    content: const Text(
                                      'Item added to cart successfully!',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          dismissedByTimer =
                                          false; // User pressed manually
                                          Navigator.of(
                                            context,
                                          ).pop(); // Close dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                                );
                              }
                            } catch (e) {
                              print(
                                'Failed to add item to cart: $e',
                              );
                            }
                        },
                        onDirection: (){},
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

bool _isPressed = false;

class ItemCard extends StatelessWidget {
  final int? itemcode;
  final String itemName;
  final String itemBrand;
  final String itemUnit;
  final double itemPrice;
  final String itemDescription;
  final String storeName;
  final LatLng? currentPosition;
  final double? tempDistanceRadius;
  final String? tempStoreType;
  final String? tempPriceRange;
  final String? tempItemGroup;
  final VoidCallback onAdd;
  final VoidCallback onDirection;

  const ItemCard({
    super.key,
    required this.itemcode,
    required this.itemName,
    required this.itemBrand,
    required this.itemUnit,
    required this.itemPrice,
    required this.itemDescription,
    required this.storeName,
    required this.currentPosition,
    required this.tempDistanceRadius,
    required this.tempStoreType,
    required this.tempPriceRange,
    required this.tempItemGroup,
    required this.onAdd,
    required this.onDirection
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Container(
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
                  TableRow(
                    children: [
                      Text(
                        'Name: $itemName',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                        softWrap: true,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(
                        'Store: $storeName',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(
                        'Price: RM ${itemPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A7BE7),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Buttons: Add + Directions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: Icon(Icons.shopping_cart_outlined, size: 25),
                    label: Text(
                      'Add',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.directions,
                      size: 35,
                      color: Colors.black87,
                    ),
                    onPressed: onDirection,
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
