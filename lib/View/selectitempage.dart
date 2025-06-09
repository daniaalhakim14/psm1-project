import 'package:flutter/material.dart';
import 'package:fyp/View/itemcartpage.dart';

import 'compareitempage.dart';

class selectitempage extends StatefulWidget {
  const selectitempage({super.key});

  @override
  State<selectitempage> createState() => _selectitempageState();
}

class _selectitempageState extends State<selectitempage> {
  final List<Map<String, String>> items = [
    {'name': 'Susu Segar', 'brand': 'Dutch Lady', 'unit': '1L'},
    {'name': 'Telur Gred A', 'brand': 'Ayamas', 'unit': '10 pcs'},
    {'name': 'Minyak Masak', 'brand': 'Knife', 'unit': '1KG'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Text('Select Item'),
        backgroundColor: Color(0xFF5A7BE7),
        automaticallyImplyLeading: true,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Center(
            child: ItemCard(
              itemName: item['name']!,
              itemBrand: item['brand']!,
              itemUnit: item['unit']!,
              onCompare: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => compareitem()),
                );
              },
              onCart: ()  {
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
            // Image placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage('lib/Icons/no_picture.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
                      'lib/Icons/compare_icon.png',
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
