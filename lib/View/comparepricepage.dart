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

class _comparepricepageState extends State<comparepricepage> with AutomaticKeepAliveClientMixin{
  final _textControllerSearch = TextEditingController();
  int _currentPage = 0;
  // search bar
  final searchController = SearchController();
  String selectedText = '';
  Timer? _debounce;
  String _lastQuery = '';

  // new variables for temporary filter states
  double _tempDistanceRadius = 10000.0; // temporary distance filter
  String _tempStoreType = 'All'; // temporary store type filter
  // To get Location
  LatLng? _currentPosition;
  String storeType = 'All';
  // For filter dropdown usage
  bool _showFilterDropdown = false;
  OverlayEntry? _dropdownOverlay;
  // To select filter
  int _selectedFilterIndex = 0;


  // if user change letters or words in search bar
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 2000), () {
      final searchVM = Provider.of<itemPrice_viewmodel>(context, listen: false);
      searchVM.fetchItemSearch(query);
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
    final double value = appBarHeight + MediaQuery.of(context).padding.top;
    print('value: $screenWidth');

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
                                height: 180, // limit the height only for the right panel content
                                child: ListView(
                                  padding: const EdgeInsets.all(12),
                                  children: [
                                    _selectedFilterIndex == 0
                                        ? _buildStoreFilter(setOverlayState)
                                        : _buildItemFilter(setOverlayState),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Apply logic - update the actual filters
                                    final viewModel = Provider.of<itemPrice_viewmodel>(context, listen: false);
                                    viewModel.setDistanceRadius(_tempDistanceRadius);
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
                                  onTap: () {
                                    // Reset logic - reset to default values
                                    setOverlayState(() {
                                      _selectedFilterIndex = 0;
                                      _tempDistanceRadius = 10000.0;
                                      final viewModel = Provider.of<itemPrice_viewmodel>(context, listen: false);
                                      viewModel.setDistanceRadius(_tempDistanceRadius);// default distance
                                      _tempStoreType = 'All'; // default store type
                                    });
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
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;


  @override
  void initState() {
    super.initState();
    // Trigger fetching best deals once this widget is initialized
    Future.microtask(() {
      final viewModel = Provider.of<itemPrice_viewmodel>(
        context,
        listen: false,
      );
      viewModel.fetchBestDeals();
      viewModel.fetchStoreLocation();
    });

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
                              searchVM.fetchItemSearch(''); // clear results
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
                          //onSearchChanged(controller.text);
                          final query = controller.text;
                          if (query != _lastQuery) {
                            _lastQuery = query;
                            final searchVM = Provider.of<itemPrice_viewmodel>(
                              context,
                              listen: false,
                            );
                            searchVM.fetchItemSearch(query);
                          }
                          final suggestions = searchVM.itemsearch;
                          if (suggestions.isEmpty && query.isNotEmpty) {
                            // Show fallback if nothing is found
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
                          // Otherwise show matching results
                          return suggestions.map((item) {
                            return ListTile(
                              title: Text(item.itemname),
                              onTap: () {
                                setState(() {
                                  selectedText = item.itemname;
                                  searchController.closeView(item.itemname);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => selectitempage(),
                                    ),
                                  );
                                });
                              },
                            );
                          }).toList();
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
              padding: EdgeInsets.only(top: 8.0),
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      TextSpan(text: '🔍  Compare '),
                      TextSpan(
                        text: 'prices',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ', explore '),
                      TextSpan(
                        text: 'store offers',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ', and find the '),
                      TextSpan(
                        text: 'best deals near you.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
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
            SizedBox(height: 10),
            // Best deals cardholders
            Consumer<itemPrice_viewmodel>(
              builder: (context, viewModel, child) {
                if (viewModel.fetchingData) {
                  return Center(child: CircularProgressIndicator());
                }
                final deals = viewModel.bestdeals;
                if (deals.isEmpty) {
                  return Center(child: Text("No best deals available."));
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children:
                        deals.map((item) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.40,
                            height: 240,
                            margin: EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 8.0,
                            ),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.blue,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                item.itemimage != null
                                    ? Image.memory(item.itemimage!, height: 80)
                                    : Image.asset(
                                      'assets/Icons/no_picture.png',
                                      height: 80,
                                    ),
                                SizedBox(height: 6),
                                Text(
                                  item.itemname,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'RM${item.price}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Cheapest in this store',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item.premisename.toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
            SizedBox(height: 15),
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
                            if (viewModel.fetchingData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final premiseInfo = viewModel.storelocation;
                            //print("Premises received: ${premiseInfo.length}");
                            Set<Marker> storeMarkers =
                                premiseInfo
                                    .where((location) {
                                      if (_currentPosition == null ||
                                          location.latitude == null ||
                                          location.longitude == null) {
                                        print('failed to show marker');
                                        return false;
                                      }

                                      double distanceInMeters =
                                          Geolocator.distanceBetween(
                                            _currentPosition!.latitude,
                                            _currentPosition!.longitude,
                                            location.latitude!,
                                            location.longitude!,
                                          );

                                      return distanceInMeters <=
                                          viewModel.distanceRadius; // from declaration
                                    })
                                    .map((location) {
                                      return Marker(
                                        markerId: MarkerId(
                                          location.premiseid.toString(),
                                        ),
                                        position: LatLng(
                                          location.latitude!,
                                          location.longitude!,
                                        ),
                                        infoWindow: InfoWindow(
                                          title:
                                              location.premisename ??
                                              'Not Available',
                                          snippet:
                                              'Store Type: ${location.premisetype ?? 'Unknown'}',
                                        ),
                                      );
                                    })
                                    .toSet();

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
            _buildStoreType('All', 'All', setOverlayState),
            _buildStoreType('Borong', 'Borong', setOverlayState),
            _buildStoreType('Foodcourt', 'Foodcourt', setOverlayState),
            _buildStoreType('Hypermarket', 'Hypermarket', setOverlayState),
            _buildStoreType('Kedai Runcit', 'Kedai Runcit', setOverlayState),
            _buildStoreType('Kedai Serbaneka', 'Kedai Serbaneka', setOverlayState),
            _buildStoreType('Medan Selera', 'Medan Selera', setOverlayState),
            _buildStoreType('Pasar Basah', 'Pasar Basah', setOverlayState),
            _buildStoreType('Pasar Mini', 'Pasar Mini', setOverlayState),
            _buildStoreType('Pasar Raya / Supermarket', 'Pasar Raya / Supermarket', setOverlayState),
            _buildStoreType('Restoran Cina', 'Restoran Cina', setOverlayState),
            _buildStoreType('Restoran India Muslim', 'Restoran India Muslim', setOverlayState),
            _buildStoreType('Restoran Melayu', 'Restoran Melayu', setOverlayState),
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
        Text('Store Type', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: [
            Text("egg"),
            Text("Hypermarket"),
            Text("Mini Mart"),
          ],
        ),
      ],
    ),
  );

  Widget _buildDistanceButton(String label, double radius, StateSetter setOverlayState) {
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
        width: 80,
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

  // Update your _buildStoreType method - needs setOverlayState parameter
  Widget _buildStoreType(String label, String type, StateSetter setOverlayState) {
    bool isSelected = _tempStoreType == type;
    return GestureDetector(
      onTap: () {
        setOverlayState(() {
          _tempStoreType = type;
        });
      },
      child: Container(
        width: 80,
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
                  fontSize: 10
              ),
            ),
          ),
        ),
      ),
    );
  }
}
