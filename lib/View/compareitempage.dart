import 'package:flutter/material.dart';
import 'package:fyp/View/itemcartpage.dart';

class compareitem extends StatefulWidget {
  const compareitem({super.key});

  @override
  State<compareitem> createState() => _compareitemState();
}

class _compareitemState extends State<compareitem> {
  final List<Map<String, String>> items = [
    {'Store': 'Lotus', 'Price': 'Rm 4.30', 'Distance': '3.4km'},
    {'Store': 'Aeon', 'Price': 'Rm 4.80', 'Distance': '2.4km'},
    {'Store': '99 Speedmart', 'Price': 'RM5.00', 'Distance': '4.5km'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Text('Compare Item Prices'),
        backgroundColor: Color(0xFF5A7BE7),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Item: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: 'Sos Cili'),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Brand: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: 'Maggie'),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Unit: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: '340g'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Center(
                  child: ItemCard(
                    storeName: item['Store']!,
                    price: item['Price']!,
                    distance: item['Distance']!,
                    onDistance: () => print('Compare ${item['Store']}'),
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
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final String storeName;
  final String price;
  final String distance;
  final VoidCallback onDistance;
  final VoidCallback onCart;

  const ItemCard({
    super.key,
    required this.storeName,
    required this.price,
    required this.distance,
    required this.onDistance,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.14,
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
                          'Store Name: $storeName',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'Distance: $distance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'Price: $price',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
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
                onTap: onDistance,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined, size: 35),
                    //Image.asset('lib/Icons/compare_icon.png', width: 35, height: 35),
                    SizedBox(height: 4),
                    Text(
                      'Direction',
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
