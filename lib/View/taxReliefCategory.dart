import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fyp/View/taxReliefItem.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import '../ViewModel/taxRelief/taxRelief_viewmodel.dart';

class taxReliefCategory extends StatefulWidget {
  final int categoryId;
  const taxReliefCategory({required this.categoryId, Key? key})
    : super(key: key);

  @override
  State<taxReliefCategory> createState() => _taxReliefCategoryState();
}

class _taxReliefCategoryState extends State<taxReliefCategory> {
  @override
  void initState() {
    super.initState();
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
        // Fetch tax relief categories for the user - this will include our specific category
        viewModel.fetchTaxReliefCategory(userid, token);
        viewModel.fetchTaxReliefItem(userid, widget.categoryId, token);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7BE7),
        automaticallyImplyLeading: true,
        title: Consumer<TaxReliefViewModel>(
          builder: (context, viewModel, _) {
            final categoryname =
                viewModel.taxReliefCategory.isNotEmpty
                    ? viewModel.taxReliefCategory
                        .firstWhere(
                          (cat) => cat.reliefcategoryid == widget.categoryId,
                          orElse: () => viewModel.taxReliefCategory.first,
                        )
                        .categoryName
                    : 'Tax Relief';
            return Text(
              categoryname,
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
                  if (viewModel.taxReliefCategory.isEmpty) {
                    return const Text("No tax relief data found.");
                  }
                  // Find the specific category for this page
                  final currentCategory = viewModel.taxReliefCategory
                      .firstWhere(
                        (cat) => cat.reliefcategoryid == widget.categoryId,
                        orElse: () => viewModel.taxReliefCategory.first,
                      );
                  final reliefType = currentCategory.categoryName;
                  final description =
                      currentCategory.description ?? 'No description available';
                  final totalUsed = currentCategory.totalUsed;
                  final maxAllowed = currentCategory.totalAvailable;

                  return Column(
                    children: [
                      _buildSummaryCard(
                        reliefType,
                        maxAllowed,
                        totalUsed,
                        currentCategory.iconImage,
                      ),
                      const SizedBox(height: 8),
                      _buildDescriptionBox(description),
                      const SizedBox(height: 8),
                      // Since we consolidated models, we show the category info as a card
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
                                            (context) => taxReliefItem(
                                              categoryId: item.reliefitemid,
                                              iconImage:
                                                  currentCategory.iconImage,
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
                      /*
                      TaxReliefCard(
                        title: currentCategory.categoryName,
                        max: currentCategory.totalAvailable,
                        used: currentCategory.totalUsed,
                      ),
                       */
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

class TaxExemptCard extends StatefulWidget {
  //final List<int>? iconBytes;
  final String title;
  final String subtitle;
  final double used;
  final double limit;
  final VoidCallback onTap;

  const TaxExemptCard({
    //required this.iconBytes,
    required this.title,
    required this.subtitle,
    required this.used,
    required this.limit,
    required this.onTap,
  });

  @override
  _TaxExemptCardState createState() => _TaxExemptCardState();
}

class _TaxExemptCardState extends State<TaxExemptCard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progressValue = widget.limit > 0 ? widget.used / widget.limit : 0.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: screenWidth * 0.98,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFF5A7BE7), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Icon container with circular background
                /*
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFE3ECF5),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade300,
                    child:
                    widget.iconBytes != null
                        ? ClipOval(
                      child: Image.memory(
                        Uint8List.fromList(widget.iconBytes!),
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
                ),
                const SizedBox(width: 16),
                 */
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Used amount text
                Text(
                  '${widget.used.toStringAsFixed(2)} used',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A7BE7)),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            // View details text
            const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'view details',
                style: TextStyle(fontSize: 12, color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
