import 'package:flutter/material.dart';
class itemcart extends StatefulWidget {
  const itemcart({super.key});

  @override
  State<itemcart> createState() => _itemcartState();
}

class _itemcartState extends State<itemcart> {
  final List<Map<String, String>> items = [
    {'name': 'Susu Segar', 'brand': 'Dutch Lady', 'unit': '1L'},
    {'name': 'Telur Gred A', 'brand': 'Ayamas', 'unit': '10 pcs'},
    {'name': 'Minyak Masak', 'brand': 'Knife', 'unit': '1KG'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        automaticallyImplyLeading: true,
      ),
      body:  ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Center(
            child: ItemCard(
              itemName: item['name']!,
              itemBrand: item['brand']!,
              itemUnit: item['unit']!,
              onQuantity: () => print('Add ${item['name']} to cart'),
              onRemove: () => print('Add ${item['name']} to cart'),
            ),
          );
        },
      ),
    );
  }
}
class QuantityControl extends StatefulWidget {
  final void Function(int)? onChanged;

  const QuantityControl({super.key, this.onChanged});

  @override
  State<QuantityControl> createState() => _QuantityControlState();
}

class _QuantityControlState extends State<QuantityControl> {
  int quantity = 1;

  void _increment() {
    setState(() => quantity++);
    widget.onChanged?.call(quantity);
  }

  void _decrement() {
    if (quantity > 1) {
      setState(() => quantity--);
      widget.onChanged?.call(quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove, size: 18), // Smaller icon
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 30, minHeight: 30),
          onPressed: _decrement,
        ),
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$quantity',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add, size: 18),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 30, minHeight: 30),
          onPressed: _increment,
        ),
      ],
    );
  }
}

class ItemCard extends StatelessWidget {
  final String itemName;
  final String itemBrand;
  final String itemUnit;
  final VoidCallback onQuantity;
  final VoidCallback onRemove;

  const ItemCard({
    super.key,
    required this.itemName,
    required this.itemBrand,
    required this.itemUnit,
    required this.onQuantity,
    required this.onRemove,
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
            Expanded(
              //height: screenHeight * 0.1,
              //width: screenWidth * 0.44,
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
            // add quantity button
            QuantityControl(
              onChanged: (value) => print('Quantity updated: $value'),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red, size: 32),
              constraints: BoxConstraints(),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item removed')),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
