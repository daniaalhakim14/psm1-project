import "dart:typed_data";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:fyp/ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart";
import "package:fyp/ViewModel/taxRelief/taxRelief_viewmodel.dart";
import "package:percent_indicator/linear_percent_indicator.dart";
import "package:provider/provider.dart";

class taxReliefItem extends StatefulWidget {
  const taxReliefItem({
    required this.categoryId,
    required this.iconImage,
    Key? key,
  }) : super(key: key);
  final int categoryId;
  final List<int>? iconImage;

  @override
  State<taxReliefItem> createState() => _taxReliefItemState();
}

class _taxReliefItemState extends State<taxReliefItem> {
  @override
  void initState() {
    super.initState();
    // Initialization code here
    final userid =
        Provider.of<signUpnLogin_viewmodel>(
          context,
          listen: false,
        ).userInfo!.id;
    final token =
        Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
    if (token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = Provider.of<TaxReliefViewModel>(
          context,
          listen: false,
        );
        viewModel.fetchTaxReliefItem(userid, widget.categoryId, token);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7BE7),
        title: Consumer<TaxReliefViewModel>(
          builder: (context, viewModel, _) {
            final itemname = viewModel.taxReliefItem.isNotEmpty ? viewModel.taxReliefItem.firstWhere(
                  (item) => item.reliefitemid == widget.categoryId,
              orElse: () => viewModel.taxReliefItem.first,).itemname : 'Tax Relief';
            return Text(
              itemname,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Consumer<TaxReliefViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.fetchingData) {
                    return Center(child: const CircularProgressIndicator());
                  }
                  // Find the specific category for this page
                  final currentItem = viewModel.taxReliefItem.firstWhere(
                        (cat) => cat.reliefitemid == widget.categoryId, orElse: () => viewModel.taxReliefItem.first,
                  );
                  final reliefType = currentItem.itemname;
                  final description = currentItem.description ?? 'No description available';
                  final totalUsed = currentItem.totalItemClaimedAmount ?? 0.0;
                  final maxAllowed = currentItem.totalItemReliefLimit ?? 0.0;

                  if (viewModel.taxReliefItem.isEmpty) {
                    return const Text("No tax relief item found.");
                  }

                  return Column(
                    children: [
                      _buildSummaryCard(
                        reliefType,
                        maxAllowed,
                        totalUsed,
                        widget.iconImage,
                      ),
                      const SizedBox(height: 8),
                      _buildDescriptionBox(description),
                      const SizedBox(height: 8),
                      // Since we consolidated models, we show the category info as a card
                      /*
                      Container(
                        height: 400, // Fixed height instead of Expanded
                        child: Consumer<TaxReliefViewModel>(
                          builder: (context, viewModel, _) {
                            if (viewModel.fetchingData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (viewModel.taxReliefItem.isEmpty) {
                              return Center(
                                child: Text(
                                  'No tax relief item available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }

                            // Show Tax Relief Category
                            return ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              itemCount: viewModel.taxReliefItem.length,
                              itemBuilder: (context, index) {
                                final item = viewModel.taxReliefItem[index];
                                return TaxExemptCard(
                                  //iconBytes: category.iconImage,
                                  title: item.itemname,
                                  subtitle:
                                      'Up to RM${item.amountCanClaim.toStringAsFixed(2)}',
                                  used: item.eligibleAmount,
                                  limit: item.amountCanClaim,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => taxReliefCategory(
                                              categoryId: item.reliefitemid,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          
                          
                          },
                        ),
                      ),
                      */
                      TaxReliefCard(
                        title: currentItem.itemname,
                        max: currentItem.totalItemReliefLimit ?? 0.0,
                        used: currentItem.totalItemClaimedAmount ?? 0.0,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String reliefType,
    double maxAllowed,
    double totalUsed,
    List<int>? iconBytes,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double percent = (totalUsed / maxAllowed).clamp(0.0, 1.0);

    return SizedBox(
      width: screenWidth * 0.95,
      height: screenHeight * 0.15,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade300,
                    child:
                        iconBytes != null
                            ? ClipOval(
                              child: Image.memory(
                                Uint8List.fromList(iconBytes),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ),
                            )
                            : const Icon(
                              Icons.receipt,
                              size: 24,
                              color: Color(0xFF5A7BE7),
                            ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Type: $reliefType",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "RM${totalUsed.toStringAsFixed(2)} / RM${maxAllowed.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearPercentIndicator(
                lineHeight: 8,
                percent: percent,
                progressColor: Colors.blue,
                backgroundColor: Colors.grey.shade300,
                barRadius: const Radius.circular(10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionBox(String description) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.95,
      child: Card(
        elevation: 2,
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📘 Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              const Text(
                "📌 Disclosures",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "• Claims must be backed with valid documentation (e.g., receipts, certificates).\n"
                "• Limits apply per relief type.\n"
                "• Some claims require special certifications (e.g., JKM or medical confirmation).",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaxReliefCard extends StatefulWidget {
  final String title;
  final double max;
  final double used;

  const TaxReliefCard({
    required this.title,
    required this.max,
    required this.used,
    Key? key,
  }) : super(key: key);

  @override
  State<TaxReliefCard> createState() => _TaxReliefCardState();
}

class _TaxReliefCardState extends State<TaxReliefCard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double percent = (widget.used / widget.max).clamp(0.0, 1.0);

    return Container(
      width: screenWidth * 0.95,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Eligible: RM${widget.max.toStringAsFixed(2)}"),
              Text("Claimed: RM${widget.used.toStringAsFixed(2)}"),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey.shade300,
                color: Colors.green,
                minHeight: 6,
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              // TODO: Handle receipt tap
              print('Tapped receipt for ${widget.title}');
            },
          ),
        ),
      ),
    );
  }
}
