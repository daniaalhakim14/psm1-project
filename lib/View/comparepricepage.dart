import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/View/homepage.dart';
import 'package:fyp/View/selectitempage.dart';
import 'package:fyp/View/taxexempt.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../Model/signupLoginpage.dart';
import '../ViewModel/itemPricePremise/itemPrice_viewmodel.dart';
import 'accountpage.dart';

class comparepricepage extends StatefulWidget {
  final UserInfoModule userInfo;
  const comparepricepage({super.key, required this.userInfo});

  @override
  State<comparepricepage> createState() => _comparepricepageState();
}

class _comparepricepageState extends State<comparepricepage>
    with AutomaticKeepAliveClientMixin {
  final _textControllerSearch = TextEditingController();
  int _currentPage = 0;
  // search bar
  final searchController = SearchController();
  String selectedText = '';
  Timer? _debounce;
  String _lastQuery = '';

  // new variables for temporary filter states
  double _tempDistanceRadius = 10000.0; // temporary distance filter
  String _tempStoreType = ''; // temporary store type filter
  String _tempPriceRange = '';
  String _tempItemGroup = '';
  // To get Location
  LatLng? _currentPosition;
  String storeType = '';
  // For filter dropdown usage
  bool _showFilterDropdown = false;
  OverlayEntry? _dropdownOverlay;
  // To select filter
  int _selectedFilterIndex = 0;
  bool _isLoading = true;

  // if user change letters or words in search bar
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 2000), () {
      final searchVM = Provider.of<itemPrice_viewmodel>(context, listen: false);
      searchVM.fetchItemSearch(
        query,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        searchVM.distanceRadius,
        searchVM.storeType,
        searchVM.priceRange,
        searchVM.itemGroup,
      );
    });
  }

  // Filter Dropdown
  void _toggleDropdown(BuildContext context) {
    if (_showFilterDropdown) {
      _dropdownOverlay?.remove();
      _showFilterDropdown = false;
      return;
    }

    final double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? 65;
    final double screenWidth = MediaQuery.of(context).size.width;

    _dropdownOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: appBarHeight,
          width: screenWidth,
          child: Material(
            elevation: 8,
            child: StatefulBuilder(
              builder:
                  (context, setOverlayState) => Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left Section: Filter Categories
                              Container(
                                width: 104,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setOverlayState(() {
                                          _selectedFilterIndex = 0;
                                        });
                                      },
                                      child: Container(
                                        width: 80,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              _selectedFilterIndex == 0
                                                  ? Color(0xFF5A7BE7)
                                                  : Color(0xFFE3ECF5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Store',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () {
                                        setOverlayState(() {
                                          _selectedFilterIndex = 1;
                                        });
                                      },
                                      child: Container(
                                        width: 80,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              _selectedFilterIndex == 1
                                                  ? Color(0xFF5A7BE7)
                                                  : Color(0xFFE3ECF5),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Items',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Right Section: Filter Options
                              SizedBox(
                                width: 240,
                                height:
                                    180, // limit the height only for the right panel content
                                child: ListView(
                                  padding: const EdgeInsets.all(12),
                                  children: [
                                    _selectedFilterIndex == 0
                                        // Has filter options for Store & Item
                                        ? _buildStoreFilter(setOverlayState)
                                        : _buildItemFilter(setOverlayState),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    // Apply logic - update the actual filters
                                    final viewModel =
                                        Provider.of<itemPrice_viewmodel>(
                                          context,
                                          listen: false,
                                        );
                                    viewModel.setDistanceRadius(
                                      _tempDistanceRadius,
                                    );
                                    viewModel.setStoreType(_tempStoreType);
                                    viewModel.setPriceRange(_tempPriceRange);
                                    viewModel.setItemGroup(_tempItemGroup);
                                    // Fetch updated best deals after changing radius
                                    final position =
                                        _currentPosition; // assuming you store it from Geolocator
                                    if (position != null) {
                                      await viewModel.fetchBestDeals(
                                        position.latitude,
                                        position.longitude,
                                        _tempDistanceRadius,
                                        _tempStoreType,
                                      );
                                      await viewModel.fetchStoreLocation(
                                        position.latitude,
                                        position.longitude,
                                        _tempDistanceRadius,
                                        _tempStoreType,
                                      );
                                    }
                                    setState(() {
                                      storeType = _tempStoreType;
                                    });

                                    _dropdownOverlay?.remove();
                                    _showFilterDropdown = false;
                                  },
                                  child: Container(
                                    width: 140,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Apply',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    setOverlayState(() {
                                      _selectedFilterIndex = 0;
                                      _tempDistanceRadius = 10000.0;
                                      _tempStoreType = '';
                                    });

                                    final viewModel =
                                        Provider.of<itemPrice_viewmodel>(
                                          context,
                                          listen: false,
                                        );
                                    viewModel.setDistanceRadius(
                                      _tempDistanceRadius,
                                    );
                                    viewModel.setStoreType(_tempStoreType);
                                    viewModel.setPriceRange(_tempPriceRange);
                                    viewModel.setItemGroup(_tempItemGroup);

                                    // 🔁 Trigger updated fetch for best deals
                                    if (_currentPosition != null) {
                                      await viewModel.fetchBestDeals(
                                        _currentPosition!.latitude,
                                        _currentPosition!.longitude,
                                        _tempDistanceRadius,
                                        _tempStoreType,
                                      );
                                      await viewModel.fetchStoreLocation(
                                        _currentPosition!.latitude,
                                        _currentPosition!.longitude,
                                        _tempDistanceRadius,
                                        _tempStoreType,
                                      );
                                    } else
                                      (print('dfsfdsfdsgfdsg'));
                                    _dropdownOverlay?.remove();
                                    _showFilterDropdown = false;
                                  },
                                  child: Container(
                                    width: 140,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Reset',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_dropdownOverlay!);
    _showFilterDropdown = true;
  }

  // Request Location Permission
  Future<Position> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _initLocation() async {
    try {
      Position position = await getUserLocation();
      setState(() {
        // get users current position
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      final viewModel = Provider.of<itemPrice_viewmodel>(
        context,
        listen: false,
      );
      viewModel.fetchBestDeals(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        viewModel.distanceRadius,
        viewModel.storeType,
      );
      viewModel.fetchStoreLocation(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        viewModel.distanceRadius,
        viewModel.storeType,
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // <--- this is required
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              // Search Button
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 4.0),
                child: Consumer<itemPrice_viewmodel>(
                  builder: (context, searchVM, _) {
                    return SizedBox(
                      height: screenHeight * 0.055,
                      width: screenWidth * 0.66,
                      child: SearchAnchor.bar(
                        searchController: searchController,
                        barHintText: 'Search Items',
                        barTrailing: [
                          IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                selectedText = '';
                                _lastQuery = ''; // reset
                              });
                              final searchVM = Provider.of<itemPrice_viewmodel>(
                                context,
                                listen: false,
                              );
                              searchVM.fetchItemSearch(
                                '',
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                                _tempDistanceRadius,
                                _tempStoreType,
                                _tempPriceRange,
                                _tempItemGroup,
                              ); // clear results
                            },
                          ),
                        ],
                        barBackgroundColor: WidgetStatePropertyAll(
                          Colors.white,
                        ),
                        barShape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // <-- radius value
                            side: BorderSide(
                              color: Colors.blue,
                            ), // optional: border color
                          ),
                        ),
                        suggestionsBuilder: (context, controller) {
                          final query = controller.text;
                          if (query != _lastQuery) {
                            _lastQuery = query;
                            final searchVM = Provider.of<itemPrice_viewmodel>(
                              context,
                              listen: false,
                            );
                            searchVM.fetchItemSearch(
                              query,
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                              _tempDistanceRadius,
                              _tempStoreType,
                              _tempPriceRange,
                              _tempItemGroup,
                            );
                          }
                          final suggestions = searchVM.itemsearch;
                          if (suggestions.isEmpty && query.isNotEmpty) {
                            return [
                              ListTile(
                                title: Text(
                                  'Item not available',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.info_outline,
                                  color: Colors.grey,
                                ),
                              ),
                            ];
                          }
                          return suggestions.map((item) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(item.itemname),
                                  onTap: () {
                                    setState(() {
                                      selectedText = item.itemname;
                                      searchController.closeView(item.itemname);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => selectitempage(
                                                itemcode: item.itemcode,
                                                premiseid: item.premiseid,
                                                itemname: item.itemname,
                                                searchQuery: _lastQuery,
                                                currentPosition:
                                                    (_currentPosition),
                                                tempDistanceRadius:
                                                    _tempDistanceRadius,
                                                tempStoreType: _tempStoreType,
                                                tempPriceRange: _tempPriceRange,
                                                tempItemGroup: _tempItemGroup,
                                              ),
                                          // (context) => selectitempage(item.itemname),
                                        ),
                                      );
                                    });
                                  },
                                ),
                                Divider(height: 1, color: Colors.grey.shade300),
                              ],
                            );
                          }).toList();
                        },
                        // when enter press will go to selectitempage

                        onSubmitted: (value) async {
                          setState(() {
                            selectedText = value;
                            searchController.closeView(value);
                          });

                          // First, perform the search and wait for it to complete
                          final searchVM = Provider.of<itemPrice_viewmodel>(context, listen: false);
                          await searchVM.fetchItemSearch(
                            value,
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                            _tempDistanceRadius,
                            _tempStoreType,
                            _tempPriceRange,
                            _tempItemGroup,
                          );

                          // Then navigate after the search is complete
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => selectitempage(
                                itemcode: null,
                                premiseid: null,
                                itemname: null,
                                searchQuery: value,
                                currentPosition: (_currentPosition),
                                tempDistanceRadius: _tempDistanceRadius,
                                tempStoreType: _tempStoreType,
                                tempPriceRange: _tempPriceRange,
                                tempItemGroup: _tempItemGroup,
                              ),
                            ),
                          );
                        },
                        // other properties...
                      ),
                    );
                  },
                ),
              ),
              // filter button
              Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Builder(
                  builder:
                      (innerContext) => GestureDetector(
                        onTap:
                            () => _toggleDropdown(
                              innerContext,
                            ), // use the new context
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.filter_list_outlined, size: 30),
                        ),
                      ),
                ),
              ),
              // Cart Button
              Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: GestureDetector(
                  onTap: () {},
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
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF5A7BE7),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Page description
            Padding(
              padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Container(
                width: screenWidth * 0.95,
                height: screenHeight * 0.10,
                decoration: BoxDecoration(
                  // fully transparent:
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black26, width: 1.0),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 6),
                    Image.asset('assets/Icons/information.png', scale: 12),
                    SizedBox(width: 6),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compare Prices 🔍',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Explore store offers and find the best\ndeals near you.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            // Best deals & view all wordings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    "Best Deals",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
                // Carousel
              ],
            ),
            // Best deals cardholders
            Consumer<itemPrice_viewmodel>(
              builder: (context, viewModel, child) {
                final deals = viewModel.bestdeals;
                if (deals.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Color(0xFF5A7BE7)),
                          SizedBox(height: 10),
                          Text(
                            "Loading best deals...",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children:
                        deals.map((item) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: 240,
                            margin: EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 8.0,
                            ),
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                /* for images (for future use)
                              item.itemimage != null
                              ? Image.memory(item.itemimage!, height: 80)
                              : Image.asset(
                              'assets/Icons/no_picture.png',
                              height: 80,
                              ),
                              SizedBox(height: 6),
                               */
                                // Item name container
                                Container(
                                  width: 130,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding:  EdgeInsets.only(left:4.0,right: 4.0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Table(
                                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                        columnWidths: {0:IntrinsicColumnWidth()},
                                        children: [
                                          TableRow(
                                            children: [
                                              Text(
                                                item.itemname,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                              ),
                                            ]
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Item price
                                Text(
                                  'RM${item.price?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // "Cheapest in your area" tag
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Cheapest in your area',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Premise name container
                                Container(
                                  width: 130,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.premisename.toString(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                // Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Direction Button
                                    SizedBox(
                                      width: 75,
                                      height: 34,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/directionPage',
                                            arguments: {
                                              'storeName': item.premisename,
                                              'lat': item.latitude,
                                              'lng': item.longitude,
                                            },
                                          );
                                        },
                                        icon: Icon(Icons.directions, size: 12),
                                        label: Text(
                                          'Direction',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    // Add to Cart Button
                                    SizedBox(
                                      width: 60,
                                      height: 34,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // TODO: Add to cart logic
                                        },
                                        icon: Icon(
                                          Icons.add_shopping_cart,
                                          size: 12,
                                        ),
                                        label: Text(
                                          'Add',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
            SizedBox(height: 5),
            // Store Near You wordings
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "Stores near your areas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Google Maps
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Container(
                width: 350,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    _currentPosition == null
                        ? Center(child: CircularProgressIndicator())
                        : Consumer<itemPrice_viewmodel>(
                          builder: (context, viewModel, child) {
                            final premiseInfo = viewModel.storelocation;
                            //print("Premises received: ${premiseInfo.length}");
                            Set<Marker> storeMarkers =
                                viewModel.storelocation.map((location) {
                                  return Marker(
                                    markerId: MarkerId(
                                      location.premiseid.toString(),
                                    ),
                                    position: LatLng(
                                      location.latitude!,
                                      location.longitude!,
                                    ),
                                    icon: getMarkerColorByType(
                                      location.premisetype,
                                    ),
                                    infoWindow: InfoWindow(
                                      title:
                                          location.premisename ??
                                          'Not Available',
                                      snippet:
                                          'Store Type: ${location.premisetype ?? 'Unknown'}',
                                    ),
                                  );
                                }).toSet();

                            return GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _currentPosition!,
                                zoom: 15,
                              ),
                              markers: storeMarkers,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => homepage(userInfo: widget.userInfo),
                  ),
                );
              },
              icon: Icon(CupertinoIcons.home, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.search,
                size: 50,
                color: Color(0xFF5A7BE7),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => taxExempt(userInfo: widget.userInfo),
                  ),
                );
              },
              icon: Icon(CupertinoIcons.doc, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => accountpage(userInfo: widget.userInfo),
                  ),
                );
              },
              icon: Icon(
                CupertinoIcons.profile_circled,
                size: 48,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter Options (Distance, Store Type)
  Widget _buildStoreFilter(StateSetter setOverlayState) => Container(
    width: 240,
    padding: EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distance', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 2),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDistanceButton('5 km', 5000.0, setOverlayState),
            _buildDistanceButton('10 km', 10000.0, setOverlayState),
            _buildDistanceButton('15 km', 15000.0, setOverlayState),
            _buildDistanceButton('20 km', 20000.0, setOverlayState),
            //_buildDistanceButton('25 km', 25000.0, setOverlayState),
            //_buildDistanceButton('30 km', 30000.0, setOverlayState),
          ],
        ),
        Divider(color: Colors.grey[400], thickness: 1),
        Text('Store Type', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 2),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStoreType('Borong', 'Borong', setOverlayState),
            _buildStoreType('Foodcourt', 'Foodcourt', setOverlayState),
            _buildStoreType('Hypermarket', 'Hypermarket', setOverlayState),
            _buildStoreType('Kedai Runcit', 'Kedai Runcit', setOverlayState),
            _buildStoreType(
              'Kedai Serbaneka',
              'Kedai Serbaneka',
              setOverlayState,
            ),
            _buildStoreType('Medan Selera', 'Medan Selera', setOverlayState),
            _buildStoreType('Pasar Basah', 'Pasar Basah', setOverlayState),
            _buildStoreType('Pasar Mini', 'Pasar Mini', setOverlayState),
            _buildStoreType(
              'Pasar Raya / Supermarket',
              'Pasar Raya / Supermarket',
              setOverlayState,
            ),
            _buildStoreType('Restoran Cina', 'Restoran Cina', setOverlayState),
            _buildStoreType(
              'Restoran India Muslim',
              'Restoran India Muslim',
              setOverlayState,
            ),
            _buildStoreType(
              'Restoran Melayu',
              'Restoran Melayu',
              setOverlayState,
            ),
          ],
        ),
      ],
    ),
  );

  // Filter Options (Item Price, Item Type)
  Widget _buildItemFilter(StateSetter setOverlayState) => Container(
    width: 224,
    padding: EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 2),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPriceRange('Low to High', 'ASC', setOverlayState),
            _buildPriceRange('High to Low', 'DESC', setOverlayState),
          ],
        ),
        Divider(color: Colors.grey[400], thickness: 1),
        Text('Item Group', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 2),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildItemGroup(
              'Berbungkus',
              'BARANGAN BERBUNGKUS',
              setOverlayState,
            ),
            _buildItemGroup('Kering', 'BARANGAN KERING', setOverlayState),
            _buildItemGroup('Segar', 'BARANGAN SEGAR', setOverlayState),
            _buildItemGroup('Minuman', 'MINUMAN', setOverlayState),
            _buildItemGroup('Kebersihan', 'PRODUK KEBERSIHAN', setOverlayState),
            _buildItemGroup(
              'Bayi & Susu',
              'SUSU DAN BARANGAN BAYI',
              setOverlayState,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildDistanceButton(
    String label,
    double radius,
    StateSetter setOverlayState,
  ) {
    // Use temporary filter state instead of viewModel state
    bool isSelected = _tempDistanceRadius == radius;

    return GestureDetector(
      onTap: () {
        // Update temporary state and rebuild overlay immediately
        setOverlayState(() {
          _tempDistanceRadius = radius;
        });
      },
      child: Container(
        width: 90,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5A7BE7) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreType(
    String label,
    String type,
    StateSetter setOverlayState,
  ) {
    bool isSelected = _tempStoreType == type;
    return GestureDetector(
      onTap: () {
        setOverlayState(() {
          _tempStoreType = type;
        });
      },
      child: Container(
        width: 90,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5A7BE7) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRange(
    String label,
    String range,
    StateSetter setOverlayState,
  ) {
    bool isSelected = _tempPriceRange == range;
    return GestureDetector(
      onTap: () {
        setOverlayState(() {
          _tempPriceRange = range;
        });
      },
      child: Container(
        width: 90,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5A7BE7) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemGroup(
    String label,
    String group,
    StateSetter setOverlayState,
  ) {
    bool isSelected = _tempItemGroup == group;
    return GestureDetector(
      onTap: () {
        setOverlayState(() {
          _tempItemGroup = group;
        });
      },
      child: Container(
        width: 90,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5A7BE7) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // Colour the marker in googlemaps
  BitmapDescriptor getMarkerColorByType(String? type) {
    switch (type?.toLowerCase()) {
      case 'pasar raya / supermarket':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'hypermarket':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case 'pasar mini':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'kedai runcit':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'pasar basah':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      case 'borong':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'medan selera':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueMagenta,
        );
      case 'kedai serbaneka':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
      case 'foodcourt':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case 'restoran cina':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
      case 'restoran india muslim':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ); // reused
      case 'restoran melayu':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        ); // reused
      default:
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ); // fallback
    }
  }
}
