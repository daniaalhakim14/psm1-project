import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/View/homepage.dart';
import 'package:provider/provider.dart';
import '../Model/signupLoginpage.dart';
import '../ViewModel/itemPricePremise/itemPrice_viewmodel.dart';
import 'accountpage.dart';

class comparepricepage extends StatefulWidget {
  final UserInfoModule userInfo;
  const comparepricepage({super.key,required this.userInfo});

  @override
  State<comparepricepage> createState() => _comparepricepageState();
}

class _comparepricepageState extends State<comparepricepage> {
  final _textControllerSearch = TextEditingController();
  int _currentPage = 0;
  final searchController = SearchController();
  final List<Map<String, String>> sliderItems = [
    {'image': 'lib/Stickers/assetmanagement.png', 'title': 'Item 1'},
    {'image': 'lib/Stickers/business.png', 'title': 'Item 2'},
    {'image': 'lib/Stickers/dontletmoneyflyaway.png', 'title': 'Item 3'},
  ];
  String selectedText = '';
  Timer? _debounce;
  String _lastQuery = '';


  @override
  void initState() {
    super.initState();

  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 2000), () {
      final searchVM = Provider.of<itemPrice_viewmodel>(context, listen: false);
      searchVM.fetchItemSearch(query);
    });
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Text(
          "Compare Prices",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF5A7BE7),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text("Get the best deals on everyday items"),
            ),
            Row(
              children: [
                // detect location button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.my_location),
                    ),
                  ),
                ),
                Consumer<itemPrice_viewmodel>(
                  builder: (context, searchVM, _) {
                    return SizedBox(
                      height: screenHeight * 0.05,
                      width: screenWidth * 0.60,
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
                              final searchVM = Provider.of<itemPrice_viewmodel>(context, listen: false);
                              searchVM.fetchItemSearch(''); // clear results
                            },
                          ),
                        ],
                        barBackgroundColor: WidgetStatePropertyAll(Colors.white),
                        suggestionsBuilder: (context, controller) {
                          //onSearchChanged(controller.text);
                          final query = controller.text;
                          if (query != _lastQuery) {
                            _lastQuery = query;
                            final searchVM = Provider.of<itemPrice_viewmodel>(context, listen: false);
                            searchVM.fetchItemSearch(query);
                          }
                          final suggestions = searchVM.itemsearch;
                          return suggestions.map((item) {
                            return ListTile(
                              title: Text(item.itemname),
                              onTap: () {
                                setState(() {
                                  selectedText = item.itemname;
                                  searchController.closeView(item.itemname);
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

                // search bar
                /*
                SizedBox(
                  height: screenHeight * 0.05,
                    width: screenWidth * 0.60,
                    child:SearchAnchor.bar(
                      searchController: searchController,
                      barHintText: 'Search Items',
                      barTrailing: [
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                          },
                        ),
                      ],
                      barBackgroundColor: WidgetStatePropertyAll(Colors.white), // ✅ Background color
                      suggestionsBuilder: (context, controller) {
                        onSearchChanged(controller.text); // Debounced API call

                        final suggestions = context.watch<itemPrice_viewmodel>().itemsearch;
                        if (suggestions.isEmpty) {
                          return [ListTile(title: Text("No results"))];
                        }else{
                          print('yaaaaa');
                        }

                        return suggestions.map((item) {
                          return ListTile(
                            title: Text(item.itemname),
                            onTap: () {
                              setState(() {
                                selectedText = item.itemname;
                                searchController.closeView(item.itemname);
                              });
                            },
                          );
                        }).toList();
                      },
                      // For shape, wrap it inside a ClipRRect if needed
                    )
                    /*SearchBar(
                      leading: const Icon(Icons.search),
                      hintText: 'Search Item',
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                        )
                      ),
                      backgroundColor: WidgetStatePropertyAll(Colors.white)
                    )

                     */
                ),
                */
                // filter button
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.filter_list_outlined, size: 30),
                    ),
                  ),
                ),
                // Cart Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.shopping_cart_outlined, size: 30),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text("Best Deals"),
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
            CarouselSlider(
              items:
                  sliderItems.map((item) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(item['image']!, height: 120),
                              SizedBox(height: 10),
                              Text(
                                item['title']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
              options: CarouselOptions(
                initialPage: 0,
                enlargeCenterPage:
                    true, // enlarges image, make it stand out visually
                autoPlay: true, // automatic sliding of carousel image
                reverse: false, // false, makes it move left to right
                enableInfiniteScroll: true, // true, loop infinitely
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 1500),
                scrollDirection: Axis.horizontal,
                onPageChanged: (value, _) {
                  setState(() {
                    _currentPage = value;
                  });
                },
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "Stores near your areas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                width: 350,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
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
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => homepage(userInfo:widget.userInfo,),),
              );},
              icon: Icon(CupertinoIcons.home, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.search, size: 50, color: Color(0xFF5A7BE7)),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.doc, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => accountpage(userInfo: widget.userInfo)),
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
}
