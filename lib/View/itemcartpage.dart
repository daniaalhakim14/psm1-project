import 'package:flutter/material.dart';
import 'package:fyp/Model/cart.dart';
import 'package:fyp/ViewModel/cart/cart_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';

class itemcart extends StatefulWidget {
  final LatLng? currentPosition;
  final double? tempDistanceRadius;
  final String? tempStoreType;
  final String? tempPriceRange;
  final String? tempItemGroup;

  const itemcart({
    super.key,
    required this.currentPosition,
    required this.tempDistanceRadius,
    required this.tempStoreType,
    required this.tempPriceRange,
    required this.tempItemGroup,
  });

  @override
  State<itemcart> createState() => _itemcartState();
}

class _itemcartState extends State<itemcart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<signUpnLogin_viewmodel>(context, listen: false).userInfo!.id;
      final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
      if (token != null && userId != null) {
        Provider.of<cartViewModel>(context, listen: false).fetchViewItemCart(userId, token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<cartViewModel>(context);
    final cartItems = viewModel.viewItemCart;
    final token = Provider.of<signUpnLogin_viewmodel>(context).authToken;

    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        title: const Text('Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5A7BE7),
        automaticallyImplyLeading: true,
      ),
      body: viewModel.fetchingData
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Center(
            child: ItemCard(
              itemName: "Item Code: ${item.itemcode}",
              itemBrand: item.brand ?? 'N/A',
              itemUnit: item.unit ?? 'N/A',
              itemWeight: '', // If you have weight info, add here
              quantity: item.quantity,
              onRemove: () {
                if (token != null) {
                  Provider.of<cartViewModel>(context, listen: false)
                      .deleteItemCart(item.cartId, token)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item removed')));
                    // Refresh cart list
                    final userId = Provider.of<signUpnLogin_viewmodel>(context, listen: false).userInfo!.id;
                    Provider.of<cartViewModel>(context, listen: false).fetchViewItemCart(userId, token);
                  });
                }
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
  final String itemWeight;
  final int quantity;
  final VoidCallback onRemove;

  const ItemCard({
    super.key,
    required this.itemName,
    required this.itemBrand,
    required this.itemUnit,
    required this.itemWeight,
    required this.quantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.95,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF5A7BE7), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Placeholder image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage('assets/Icons/no_picture.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Item Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Brand: $itemBrand'),
                Text('Unit: $itemUnit'),
                if (itemWeight.isNotEmpty) Text('Weight: $itemWeight'),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text("Qty: $quantity", style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
