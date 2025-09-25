import 'package:flutter/material.dart';
import 'package:fyp/Model/cart.dart';
import 'package:fyp/Model/itemPricePremise.dart';
import 'package:fyp/View/itemcartpage.dart';
import 'package:fyp/ViewModel/cart/cart_viewmodel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
    final viewModel = Provider.of<itemPrice_viewmodel>(context);

    List<dynamic> items;
    if (widget.itemcode != null && widget.premiseid != null) {
      // Coming from ListTile tap - use itemprice
      items = viewModel.itemprice;
    } else {
      // Coming from onSubmitted - use itemsearch
      items = viewModel.itemsearch;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Item',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 5),
          if (viewModel.fetchingData)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Center(
                    child: ItemCard(
                      item: item,
                      onCompare: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => compareitem(
                                  itemcode: item.itemcode,
                                  itemname: item.itemname,
                                  currentPosition: (widget.currentPosition!),
                                  tempDistanceRadius:
                                      widget.tempDistanceRadius!,
                                  tempStoreType: widget.tempStoreType!,
                                  tempPriceRange: widget.tempPriceRange!,
                                  tempItemGroup: widget.tempItemGroup,
                                ),
                          ),
                        );
                      },
                      onCart: () async {
                        final userId =
                            Provider.of<signUpnLogin_viewmodel>(
                              context,
                              listen: false,
                            ).userInfo!.id;
                        final token =
                            Provider.of<signUpnLogin_viewmodel>(
                              context,
                              listen: false,
                            ).authToken;
                        final viewModel = Provider.of<cartViewModel>(
                          context,
                          listen: false,
                        );

                        AddItemCart itemCartData = AddItemCart(
                          userid: userId,
                          itemcode: item.itemcode,
                          brand: item.brand,
                          unit: item.unit,
                          quantity: 1,
                        );
                        try {
                          if (token != null) {
                            await viewModel.addItemCart(itemCartData, token);

                            bool dismissedByTimer = true;

                            await showDialog(
                              context: context,
                              barrierDismissible:
                                  false, // Prevent dismiss by tapping outside
                              builder: (BuildContext context) {
                                // Start a delayed close
                                Future.delayed(Duration(seconds: 3), () {
                                  if (dismissedByTimer &&
                                      Navigator.canPop(context)) {
                                    Navigator.of(
                                      context,
                                    ).pop(); // Auto close after 3s
                                  }
                                });

                                return AlertDialog(
                                  title: const Text('Success'),
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
                          print('Failed to add item to cart: $e');
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final itemPrice item;
  final VoidCallback onCompare;
  final VoidCallback onCart;

  const ItemCard({
    super.key,
    required this.item,
    required this.onCompare,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showItemDetails(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.98,
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
                          'Name: ${item.itemname}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'Brand: ${item.brand ?? 'NOT AVAILABLE'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'Unit: ${item.unit ?? ''}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'Description: ${item.description ?? 'No description'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                          'Price: RM ${(item.price ?? 0.0).toStringAsFixed(2)}',
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

                // Buttons: Compare + Add
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onCompare,
                      icon: Icon(Icons.compare_arrows, size: 28),
                      label: Text(
                        'Compare',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5A7BE7),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: onCart,
                      icon: Icon(Icons.shopping_cart_outlined, size: 28),
                      label: Text(
                        'Add',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
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
      ),
    );
  }

  void _showItemDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemDetailsModal(item: item),
    );
  }
}

class _ItemDetailsModal extends StatefulWidget {
  final itemPrice item;

  const _ItemDetailsModal({required this.item});

  @override
  _ItemDetailsModalState createState() => _ItemDetailsModalState();
}

class _ItemDetailsModalState extends State<_ItemDetailsModal> {
  double? distance;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  Future<void> _calculateDistance() async {
    try {
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // If the item has premise coordinates, calculate distance
      if (widget.item.premisename != null) {
        // For now, we'll show "Calculating..." since we don't have coordinates
        // In a real implementation, you'd need premise coordinates from the API
        setState(() {
          distance = null; // Will show "Distance not available"
        });
      }
    } catch (e) {
      print('Error calculating distance: $e');
      setState(() {
        distance = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Item Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A7BE7),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Image (if available)
                      if (widget.item.itemimage != null)
                        Container(
                          width: double.infinity,
                          height: 200,
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              widget.item.itemimage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[100],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // Item Information
                      _buildDetailSection('Item Information', [
                        _buildDetailRow('Name', widget.item.itemname),
                        _buildDetailRow(
                          'Brand',
                          widget.item.brand ?? 'Not Available',
                        ),
                        _buildDetailRow(
                          'Unit',
                          widget.item.unit ?? 'Not Available',
                        ),
                        _buildDetailRow(
                          'Description',
                          widget.item.description ?? 'No description available',
                        ),
                        _buildDetailRow(
                          'Category',
                          widget.item.itemcategory ?? 'Not Available',
                        ),
                        _buildDetailRow(
                          'Group',
                          widget.item.itemgroup ?? 'Not Available',
                        ),
                      ]),

                      SizedBox(height: 20),

                      // Pricing Information
                      _buildDetailSection('Pricing', [
                        _buildDetailRow(
                          'Price',
                          'RM ${(widget.item.price ?? 0.0).toStringAsFixed(2)}',
                          valueStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A7BE7),
                          ),
                        ),
                      ]),

                      SizedBox(height: 20),

                      // Store Information
                      _buildDetailSection('Store Information', [
                        _buildDetailRow(
                          'Store Name',
                          widget.item.premisename ?? 'Not Available',
                        ),
                        _buildDetailRow(
                          'Store Type',
                          widget.item.premisetype ?? 'Not Available',
                        ),
                        _buildDetailRow(
                          'Address',
                          widget.item.address ?? 'Not Available',
                        ),
                        _buildDetailRow(
                          'District',
                          widget.item.district ?? 'Not Available',
                        ),
                        _buildDetailRow(
                          'State',
                          widget.item.state ?? 'Not Available',
                        ),
                        _buildDetailRow(
                          'Distance',
                          distance != null
                              ? '${distance!.toStringAsFixed(2)} km'
                              : 'Distance not available',
                        ),
                      ]),

                      SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // You can trigger the compare action here if needed
                              },
                              icon: Icon(Icons.compare_arrows),
                              label: Text('Compare Prices'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF5A7BE7),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // You can trigger the add to cart action here if needed
                              },
                              icon: Icon(Icons.shopping_cart),
                              label: Text('Add to Cart'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF9800),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5A7BE7),
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
