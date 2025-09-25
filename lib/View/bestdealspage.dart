import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../Model/itemPricePremise.dart';
import '../Model/cart.dart';
import '../Model/signupLoginpage.dart';
import '../ViewModel/itemPricePremise/itemPrice_viewmodel.dart';
import '../ViewModel/cart/cart_viewmodel.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';

class BestDealsPage extends StatefulWidget {
  const BestDealsPage({super.key});

  @override
  State<BestDealsPage> createState() => _BestDealsPageState();
}

class _BestDealsPageState extends State<BestDealsPage> {
  Position? _currentPosition;
  String _sortBy = 'distance'; // 'distance', 'price', 'name'

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  List<itemBestDeals> _sortDeals(List<itemBestDeals> deals) {
    List<itemBestDeals> sortedDeals = List.from(deals);

    switch (_sortBy) {
      case 'price':
        sortedDeals.sort((a, b) {
          if (a.price == null && b.price == null) return 0;
          if (a.price == null) return 1;
          if (b.price == null) return -1;
          return a.price!.compareTo(b.price!);
        });
        break;
      case 'name':
        sortedDeals.sort((a, b) => a.itemname.compareTo(b.itemname));
        break;
      case 'distance':
      default:
        if (_currentPosition != null) {
          sortedDeals.sort((a, b) {
            if (a.latitude == null || a.longitude == null) return 1;
            if (b.latitude == null || b.longitude == null) return -1;

            double distanceA = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              a.latitude!,
              a.longitude!,
            );
            double distanceB = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              b.latitude!,
              b.longitude!,
            );
            return distanceA.compareTo(distanceB);
          });
        }
        break;
    }

    return sortedDeals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        backgroundColor: Color(0xFF5A7BE7),
        title: Text(
          'Best Deals',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              // Refresh the best deals data
              final viewModel = Provider.of<itemPrice_viewmodel>(
                context,
                listen: false,
              );
              if (_currentPosition != null) {
                viewModel.fetchBestDeals(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  viewModel.distanceRadius,
                  viewModel.storeType,
                );
              }
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Sort and filter options
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'Sort by:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    underline: Container(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _sortBy = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'distance',
                        child: Text('Distance'),
                      ),
                      DropdownMenuItem(
                        value: 'price',
                        child: Text('Price (Low to High)'),
                      ),
                      DropdownMenuItem(
                        value: 'name',
                        child: Text('Name (A-Z)'),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.sort, color: Color(0xFF5A7BE7)),
              ],
            ),
          ),

          // Deals list
          Expanded(
            child: Consumer<itemPrice_viewmodel>(
              builder: (context, viewModel, child) {
                final deals = _sortDeals(viewModel.bestdeals);
                final isLoading = viewModel.fetchingData;

                if (deals.isEmpty) {
                  if (isLoading) {
                    // Still loading - show loading indicator
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF5A7BE7)),
                            SizedBox(height: 16),
                            Text(
                              "Loading best deals...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Done loading but no results - show no stores found message
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 24),
                            Text(
                              "No best deals found nearby",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Try expanding your search radius or changing your location to find more deals",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }

                // Show the list of best deals
                return ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: deals.length,
                  itemBuilder: (context, index) {
                    final deal = deals[index];
                    return _buildDealCard(context, deal);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, itemBestDeals deal) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8F9FA)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store name and type
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF5A7BE7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    deal.state ?? 'Store',
                    style: TextStyle(
                      color: Color(0xFF5A7BE7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Spacer(),
                Icon(Icons.local_offer, color: Colors.orange, size: 20),
              ],
            ),
            SizedBox(height: 12),

            // Store name
            Text(
              deal.premisename ?? 'Unknown Store',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),

            // Item name
            Text(
              deal.itemname,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),

            // Price and details row
            Row(
              children: [
                // Price
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    'RM ${deal.price?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                Spacer(),

                // Location info
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${_calculateDistance(deal)} km',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            // Address
            Row(
              children: [
                Icon(Icons.place, color: Colors.grey[500], size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    deal.address ?? 'Address not available',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // Add to Cart button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addToCart(context, deal),
                    icon: Icon(Icons.shopping_cart_outlined, size: 18),
                    label: Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // View Details button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showDealDetails(context, deal);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5A7BE7),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDistance(itemBestDeals deal) {
    // If we have current position and deal coordinates, calculate actual distance
    if (_currentPosition != null &&
        deal.latitude != null &&
        deal.longitude != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        deal.latitude!,
        deal.longitude!,
      );
      double distanceInKm = distanceInMeters / 1000;
      return distanceInKm.toStringAsFixed(1);
    }
    // Fallback to placeholder if location data is not available
    return '~';
  }

  void _addToCart(BuildContext context, itemBestDeals deal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) => _AddToCartModal(
                  deal: deal,
                  scrollController: scrollController,
                ),
          ),
    );
  }

  void _showDealDetails(BuildContext context, itemBestDeals deal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Title
                      Text(
                        'Deal Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                'Store Name',
                                deal.premisename ?? 'Unknown',
                              ),
                              _buildDetailRow(
                                'Location',
                                '${deal.district ?? 'Unknown'}, ${deal.state ?? 'Unknown'}',
                              ),
                              _buildDetailRow('Item Name', deal.itemname),
                              _buildDetailRow(
                                'Price',
                                'RM ${deal.price?.toStringAsFixed(2) ?? '0.00'}',
                              ),
                              _buildDetailRow(
                                'Address',
                                deal.address ?? 'Address not available',
                              ),

                              if (deal.latitude != null &&
                                  deal.longitude != null)
                                _buildDetailRow(
                                  'Coordinates',
                                  '${deal.latitude}, ${deal.longitude}',
                                ),

                              SizedBox(height: 20),

                              // Additional info section
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFF5A7BE7).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Why this is a great deal:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF5A7BE7),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '• Competitive pricing in your area\n• Convenient location\n• Quality products',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0xFF5A7BE7)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  color: Color(0xFF5A7BE7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _addToCart(context, deal);
                              },
                              icon: Icon(
                                Icons.shopping_cart_outlined,
                                size: 18,
                              ),
                              label: Text('Add to Cart'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}

// Add to Cart Modal Widget
class _AddToCartModal extends StatefulWidget {
  final itemBestDeals deal;
  final ScrollController scrollController;

  const _AddToCartModal({required this.deal, required this.scrollController});

  @override
  State<_AddToCartModal> createState() => _AddToCartModalState();
}

class _AddToCartModalState extends State<_AddToCartModal> {
  int _quantity = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Title
            Text(
              'Add to Cart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Item details
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.deal.itemname,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.deal.premisename ?? 'Unknown Store',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'RM ${widget.deal.price?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  if (widget.deal.brand != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'Brand: ${widget.deal.brand}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                  if (widget.deal.unit != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Unit: ${widget.deal.unit}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20),

            // Quantity selector
            Text(
              'Quantity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                // Decrease button
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed:
                        _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                    icon: Icon(Icons.remove),
                    iconSize: 20,
                  ),
                ),
                // Quantity display
                Container(
                  width: 80,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                // Increase button
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: Icon(Icons.add),
                    iconSize: 20,
                  ),
                ),
                Spacer(),
                // Total price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      'RM ${((widget.deal.price ?? 0) * _quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleAddToCart,
                    icon:
                        _isLoading
                            ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Icon(Icons.shopping_cart_outlined, size: 18),
                    label: Text(
                      _isLoading ? 'Adding...' : 'Add to Cart',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
            // Add some bottom padding to ensure content doesn't get cut off
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    setState(() => _isLoading = true);

    try {
      // Get the current user and cart view model
      final cartVm = Provider.of<cartViewModel>(context, listen: false);
      final userVm = Provider.of<signUpnLogin_viewmodel>(
        context,
        listen: false,
      );

      // Check if user is logged in
      if (userVm.userInfo == null) {
        _showErrorMessage('Please login to add items to cart');
        return;
      }

      // Create AddItemCart object
      final addItemCart = AddItemCart(
        userid: userVm.userInfo!.id,
        itemcode: widget.deal.itemcode,
        brand: widget.deal.brand,
        unit: widget.deal.unit,
        quantity: _quantity,
      );

      // Add item to cart
      await cartVm.addItemCart(addItemCart, userVm.authToken ?? '');

      // Show success message
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.deal.itemname} added to cart successfully!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Navigate to cart page
              print('Navigate to cart page');
            },
          ),
        ),
      );
    } catch (e) {
      _showErrorMessage('Failed to add item to cart: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
