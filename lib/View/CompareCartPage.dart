import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ViewModel/cart/cart_viewmodel.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';


class CompareCartPage extends StatefulWidget {
  const CompareCartPage({super.key});

  @override
  State<CompareCartPage> createState() => _CompareCartPageState();
}

class _CompareCartPageState extends State<CompareCartPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<cartViewModel>(context);
    final compareResults = viewModel.compareCart;
    final isLoading = viewModel.fetchingData;

    return Scaffold(
      backgroundColor: const Color(0xFFE3ECF5),
      appBar: AppBar(
        title: const Text(
          'Best Store Deals',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5A7BE7),
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : compareResults.isEmpty
          ? const Center(child: Text('No best deals found.'))
          : ListView.builder(
        itemCount: compareResults.length,
        itemBuilder: (context, index) {
          final store = compareResults[index];
          return StoreComparisonCard(
            premisename: store.premisename,
            matchedItems: store.matchedItems,
            distance: store.distance_km,
            totalCost: store.totalCost,
            matchedItemNames: store.matchedItemsName,
            onDirection: (){},

          );
        },
      ),
    );
  }
}

class StoreComparisonCard extends StatelessWidget {
  final String premisename;
  final int matchedItems;
  final double distance;
  final double totalCost;
  final String matchedItemNames;
  final VoidCallback onDirection;

  const StoreComparisonCard({
    super.key,
    required this.premisename,
    required this.matchedItems,
    required this.distance,
    required this.totalCost,
    required this.matchedItemNames,
    required this.onDirection
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      child: Row(
        children: [
          GestureDetector(
            child: Container(
              width: screenWidth * 0.98,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFF5A7BE7), width: 2.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: const {0: IntrinsicColumnWidth()},
                      children: [
                        TableRow(children: [
                          Text('Store: $premisename', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ]),
                        TableRow(children: [
                          SizedBox(height: 8), // spacing between rows
                        ]),
                        TableRow(children: [
                          Text('Store Distance: $distance km', style: TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                        TableRow(children: [
                          SizedBox(height: 8),
                        ]),
                        TableRow(children: [
                          Text('Matched Items: $matchedItems', style: TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                        TableRow(children: [
                          SizedBox(height: 8),
                        ]),
                        TableRow(children: [
                          Text(
                            'Total: RM ${totalCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A7BE7),
                              fontSize: 18,
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFFE3ECF5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    title: Text(premisename, style: const TextStyle(fontWeight: FontWeight.bold)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              const TextSpan(text: '📍 Distance: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '${distance.toStringAsFixed(2)} km'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              const TextSpan(text: '🧾 Matched Items: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '$matchedItems'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              const TextSpan(text: '🛒 Item Names: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: matchedItemNames),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              const TextSpan(text: '💰 Total Price: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: 'RM ${totalCost.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),

                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.directions,
              size: 35,
              color: Colors.black87,
            ),
            onPressed: onDirection
          ),
        ],
      ),
    );
  }
}
