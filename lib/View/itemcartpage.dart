import 'package:flutter/material.dart';
import 'package:fyp/Model/cart.dart';
import 'package:fyp/ViewModel/cart/cart_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import 'CompareCartPage.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final viewModel = Provider.of<cartViewModel>(context);
    final cartItems = viewModel.viewItemCart;
    final userId = Provider.of<signUpnLogin_viewmodel>(context, listen: false).userInfo!.id;
    final token = Provider.of<signUpnLogin_viewmodel>(context).authToken;

    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: GestureDetector(
              onTap: () {
                confirmDelete() {
                  if (token != null) {
                    Provider.of<cartViewModel>(context, listen: false)
                        .deleteCart(userId, token) // userId is use to get cartID
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item removed')));
                      Provider.of<cartViewModel>(context, listen: false).fetchViewItemCart(userId, token);
                    });
                  }
                }
                showDeleteConfirmationDialog(context, 'delete this item from your cart?', confirmDelete);
              },
              child: Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text('Clear Cart',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.red),)),
              ),
            ),
          ),
          
          
          ],
        ),
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
              itemName: "Item Name: ${item.itemname}",
              itemBrand: item.brand ?? 'N/A',
              itemUnit: item.unit ?? 'N/A',
              itemWeight: '', // If you have weight info, add here
              quantity: item.quantity,
              onQuantityChanged: (newQty) {
                if(newQty <= 0){
                  remove(){
                    final removeItem = RemoveItemInCart(
                      userid: userId,
                      itemcode: item.itemcode,
                    );
                    if(token != null){
                      viewModel.removeItemInCart(removeItem, token).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item removed')));
                        viewModel.fetchViewItemCart(userId, token);
                      });
                    }
                  }
                  showDeleteConfirmationDialog(context, 'delete this item from your cart?', remove);
                }else{
                  UpdateItemCartQty updateItemCartQty = UpdateItemCartQty(
                      userid: userId,
                      itemcode: item.itemcode,
                      quantity: newQty
                  );
                  print('userid: ${userId}, itemcode: ${item.itemcode}, quantity: ${newQty}');
                  if (token != null) {
                    viewModel.updateItemCartQty(updateItemCartQty, token).then((_) {
                      viewModel.fetchViewItemCart(userId, token);
                    });
                  }
                }
              },
              onRemove: () {
                remove(){
                  final removeItem = RemoveItemInCart(
                    userid: userId,
                    itemcode: item.itemcode,
                  );
                  if(token != null){
                    viewModel.removeItemInCart(removeItem, token).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item removed')));
                      viewModel.fetchViewItemCart(userId, token);
                    });
                  }
                }
                showDeleteConfirmationDialog(context, 'delete this item from your cart?', remove);
              },
            ),
          );
        },
      ),
      
      bottomNavigationBar: BottomAppBar(
        height: screenHeight * 0.13,
        color: Color(0xFFE3ECF5),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A7BE7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              if (cartItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your cart is empty. Please add items before comparing.',style: TextStyle(fontWeight: FontWeight.bold),),
                    backgroundColor: Colors.red,
                  ),
                );
                return; // Stop navigation
              }

              final compareItems = cartItems.map((item) => {
                "itemcode": item.itemcode,
                "quantity": item.quantity
              }).toList();

              final compareCartPayload = {
                "userid": userId,
                "location": {
                  "latitude": widget.currentPosition!.latitude,
                  "longitude": widget.currentPosition!.longitude
                },
                "radius": widget.tempDistanceRadius,
                "cartItems": compareItems,
              };

              try {
                if (token != null) {
                  await viewModel.fetchCompareCart(compareCartPayload, token);
                }
              } catch (e) {
                print('Failed to add item to cart: $e');
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompareCartPage(),
                ),
              );
            },

            child: const Text(
              'Find Best Deals',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
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
  final void Function(int) onQuantityChanged;

  const ItemCard({
    super.key,
    required this.itemName,
    required this.itemBrand,
    required this.itemUnit,
    required this.itemWeight,
    required this.quantity,
    required this.onRemove,
    required this.onQuantityChanged
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
          /*
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

           */
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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => onQuantityChanged(quantity - 1),
                  ),
                  Text('Qty: $quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => onQuantityChanged(quantity + 1),
                  ),
                ],
              ),

              GestureDetector(
                onTap: onRemove,
                child: Text('Remove',style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
              )

            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showDeleteConfirmationDialog(BuildContext context, String label, VoidCallback method) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), textAlign: TextAlign.center),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      method(); // run actual logic
                    },
                    child: const Text('Yes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('No', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

