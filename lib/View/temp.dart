import 'package:flutter/material.dart';
import 'package:fyp/Model/itemPricePremise.dart';
import 'package:fyp/View/itemcartpage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../ViewModel/itemPricePremise/itemPrice_viewmodel.dart';
import 'compareitempage.dart';

class selectitempage extends StatefulWidget {
  final int? premisid;
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
    required this.premisid,
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
      final viewModel = Provider.of<itemPrice_viewmodel>(context, listen: false);

      if (widget.itemcode != null &&
          widget.premisid != null &&
          widget.searchQuery != null &&
          widget.currentPosition != null &&
          widget.tempDistanceRadius != null &&
          widget.tempStoreType != null &&
          widget.tempPriceRange != null &&
          widget.tempItemGroup != null) {
        viewModel.fetchSelectedItemDetail(
          widget.premisid!,
          widget.itemcode!,
          widget.searchQuery!,
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
          widget.tempDistanceRadius!,
          widget.tempStoreType!,
          widget.tempPriceRange!,
          widget.tempItemGroup!,
        );
      } else if (widget.searchQuery != null &&
          widget.currentPosition != null &&
          widget.tempDistanceRadius != null &&
          widget.tempStoreType != null &&
          widget.tempPriceRange != null &&
          widget.tempItemGroup != null) {
        viewModel.fetchItemSearch(
          widget.searchQuery!,
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final viewModel = Provider.of<itemPrice_viewmodel>(context);
    final items = viewModel.itemprice;

    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Text('Select Item'),
        backgroundColor: Color(0xFF5A7BE7),
        automaticallyImplyLeading: true,
      ),
      body:
      viewModel.fetchingData
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Center(
            child: ItemCard(
              itemName: item.itemname,
              itemBrand: item.itemgroup ?? 'Unknown',
              itemUnit: item.unit ?? '',
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
    );
  }
}

class ItemCard extends StatelessWidget {
  final String itemName;
  final String itemBrand;
  final String itemUnit;
  final VoidCallback onCompare;
  final VoidCallback onCart;

  const ItemCard({
    super.key,
    required this.itemName,
    required this.itemBrand,
    required this.itemUnit,
    required this.onCompare,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.1,
      width: screenWidth * 0.95,
      margin: EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFF5A7BE7), width: 2.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
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
            SizedBox(width: 10),
            // Item info
            SizedBox(
              height: screenHeight * 0.1,
              width: screenWidth * 0.44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: {0: IntrinsicColumnWidth()},
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
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            // Compare button
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onCompare,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/Icons/compare_icon.png',
                      width: 35,
                      height: 35,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Compare',
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 4),
            // Cart button
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onCart,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 35),
                    SizedBox(height: 4),
                    Text(
                      'Cart',
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
