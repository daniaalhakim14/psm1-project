import "dart:typed_data";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:fyp/ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart";
import "package:fyp/ViewModel/taxRelief/taxRelief_viewmodel.dart";
import "package:fyp/Model/taxRelief.dart";
import "package:percent_indicator/linear_percent_indicator.dart";
import "package:provider/provider.dart";

class taxReliefItem extends StatefulWidget {
  const taxReliefItem({
    required this.categoryId,
    required this.itemId,
    required this.iconImage,
    Key? key,
  }) : super(key: key);
  final int categoryId, itemId;
  final List<int>? iconImage;

  @override
  State<taxReliefItem> createState() => _taxReliefItemState();
}

class _taxReliefItemState extends State<taxReliefItem> {
  bool _isDescriptionExpanded = false; // Add this state variable

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

    print("🔍 TaxReliefItem Page Debug Info:");
    print("   👤 User ID: $userid");
    print("   🏷️ Category ID (widget.categoryId): ${widget.categoryId}");
    print("   🏷️ Item ID (widget.itemId): ${widget.itemId}");
    print("   🔑 Token available: ${token != null}");

    if (token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = Provider.of<TaxReliefViewModel>(
          context,
          listen: false,
        );
        print("🚀 About to call fetchTaxReliefItem with:");
        print("   👤 userid: $userid");
        print("   🏷️ categoryId: ${widget.categoryId}");
        print("   🏷️ itemId: ${widget.itemId}");
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
            final itemname =
                viewModel.taxReliefItem.isNotEmpty
                    ? viewModel.taxReliefItem
                        .firstWhere(
                          (item) => item.reliefitemid == widget.itemId,
                          orElse: () => viewModel.taxReliefItem.first,
                        )
                        .itemname
                    : 'Tax Relief';
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
      body: Consumer<TaxReliefViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.fetchingData) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Consumer<TaxReliefViewModel>(
                    builder: (context, viewModel, _) {
                      if (viewModel.taxReliefItem.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              "No tax relief item found.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }

                      // Find the specific item for this page
                      final currentItem = viewModel.taxReliefItem.firstWhere(
                        (item) => item.reliefitemid == widget.itemId,
                        orElse: () => viewModel.taxReliefItem.first,
                      );

                      final reliefType = currentItem.itemname;
                      final description =
                          currentItem.description ?? 'No description available';
                      final totalUsed =
                          currentItem.totalItemClaimedAmount ?? 0.0;
                      final maxAllowed =
                          currentItem.totalItemReliefLimit ?? 0.0;

                      // Debug logging to understand why expenses are empty
                      print("🔍 Current Item Debug Info:");
                      print("   📋 Item Name: ${currentItem.itemname}");
                      print(
                        "   🆔 Relief Item ID: ${currentItem.reliefitemid}",
                      );
                      print("   💰 Total Used: $totalUsed");
                      print("   📊 Max Allowed: $maxAllowed");
                      print(
                        "   📝 Eligible Expenses: ${currentItem.eligibleExpenses.toString()}",
                      );
                      print(
                        "   📝 Eligible Expenses Length: ${currentItem.eligibleExpenses?.length ?? 'null'}",
                      );
                      print(
                        "   📄 Receipt: ${currentItem.receipt ?? 'No receipt'}",
                      );
                      print(
                        "   🏷️ Expense Name: ${currentItem.expensename ?? 'No expense name'}",
                      );
                      print(
                        "   💵 Expense Amount: ${currentItem.expenseamount ?? 'No expense amount'}",
                      );

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
                          // Section header for expenses
                          if (currentItem.eligibleExpenses != null &&
                              currentItem.eligibleExpenses!.isNotEmpty) ...[
                            _buildExpensesHeader(
                              currentItem.eligibleExpenses!.length,
                            ),
                            const SizedBox(height: 8),
                          ],
                          // Show list of individual expense cards
                          if (currentItem.eligibleExpenses != null &&
                              currentItem.eligibleExpenses!.isNotEmpty)
                            ..._buildExpenseCards(currentItem.eligibleExpenses!)
                          else
                            Column(
                              children: [
                                _buildNoExpensesCard(),
                                const SizedBox(height: 16),
                                // Debug button to check data
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showDebugDialog(currentItem);
                                  },
                                  icon: const Icon(Icons.bug_report),
                                  label: const Text("Debug Info"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
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
    double percent =
        maxAllowed > 0 ? (totalUsed / maxAllowed).clamp(0.0, 1.0) : 0.0;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Type: $reliefType",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "RM${totalUsed.toStringAsFixed(2)} / RM${maxAllowed.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
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
        child: Column(
          children: [
            // Header that's always visible and clickable
            InkWell(
              onTap: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      "📘 Description & Disclosures",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _isDescriptionExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expandable content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.blue, thickness: 1),
                    const SizedBox(height: 8),
                    const Text(
                      "📘 Description",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(description, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 12),
                    const Text(
                      "📌 Disclosures",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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
              crossFadeState:
                  _isDescriptionExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  void _showDebugDialog(dynamic currentItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Debug Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDebugRow("Relief Item ID", "${currentItem.reliefitemid}"),
                _buildDebugRow("Item Name", currentItem.itemname ?? 'null'),
                _buildDebugRow(
                  "Total Used",
                  "${currentItem.totalItemClaimedAmount ?? 0.0}",
                ),
                _buildDebugRow(
                  "Max Allowed",
                  "${currentItem.totalItemReliefLimit ?? 0.0}",
                ),
                _buildDebugRow("Receipt", currentItem.receipt ?? 'null'),
                _buildDebugRow(
                  "Expense Name",
                  currentItem.expensename ?? 'null',
                ),
                _buildDebugRow(
                  "Expense Amount",
                  "${currentItem.expenseamount ?? 'null'}",
                ),
                _buildDebugRow(
                  "Eligible Expenses",
                  currentItem.eligibleExpenses?.toString() ?? 'null',
                ),
                _buildDebugRow(
                  "Expenses Length",
                  "${currentItem.eligibleExpenses?.length ?? 'null'}",
                ),
                const SizedBox(height: 12),
                const Text(
                  "Possible Issues:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  "• No expenses have been added yet\n"
                  "• Expenses haven't been mapped to this category\n"
                  "• Backend API returning empty data\n"
                  "• Wrong category/item ID being used",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
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
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildExpensesHeader(int expenseCount) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.95,
      child: Row(
        children: [
          const Icon(Icons.list_alt, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            "Eligible Expenses",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$expenseCount item${expenseCount != 1 ? 's' : ''}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpenseCards(List<EligibleExpense> expenses) {
    return expenses
        .map(
          (expense) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TaxReliefCard(
              expensename: expense.expensename,
              expenseamount: expense.amount,
              eligibleamount: expense.eligibleamount,
              receipt: expense.receipt,
              confidence: expense.confidence,
              reasoning: expense.reasoning,
              date: expense.date,
            ),
          ),
        )
        .toList();
  }

  Widget _buildNoExpensesCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.95,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                "No expenses found",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "No eligible expenses have been added for this tax relief item yet.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaxReliefCard extends StatefulWidget {
  final String expensename;
  final double expenseamount;
  final double eligibleamount;
  final String? receipt;
  final double? confidence;
  final String? reasoning;
  final String? date;

  const TaxReliefCard({
    required this.expensename,
    required this.expenseamount,
    required this.eligibleamount,
    this.receipt,
    this.confidence,
    this.reasoning,
    this.date,
    Key? key,
  }) : super(key: key);

  @override
  State<TaxReliefCard> createState() => _TaxReliefCardState();
}

class _TaxReliefCardState extends State<TaxReliefCard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.95,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with expense name and receipt button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.expensename,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.date != null && widget.date!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.date!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Confidence indicator
                  if (widget.confidence != null && widget.confidence! > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(widget.confidence!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${(widget.confidence!)}%",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Receipt button
                  IconButton(
                    icon: const Icon(Icons.receipt_long),
                    onPressed: () {
                      if (widget.receipt != null &&
                          widget.receipt!.isNotEmpty) {
                        _showReceiptDialog(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No receipt available for this item'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Amount information
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Amount:",
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              "RM${widget.expenseamount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Eligible Amount:",
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              "RM${widget.eligibleamount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Progress bar showing AI confidence
                        LinearProgressIndicator(
                          value: widget.confidence ?? 0.0,
                          backgroundColor: Colors.grey.shade300,
                          color: _getConfidenceColor(widget.confidence ?? 0.0),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${((widget.confidence ?? 0.0))}% confidence",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // AI Reasoning section (if available)
              if (widget.reasoning != null && widget.reasoning!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.psychology, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    const Text(
                      "AI Reasoning:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.reasoning!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _showReceiptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.receipt, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Receipt - ${widget.expensename}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.date != null && widget.date!.isNotEmpty) ...[
                  Text(
                    "Date: ${widget.date}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  "Amount: RM${widget.expenseamount.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  "Eligible: RM${widget.eligibleamount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  "Receipt Content:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.receipt ?? 'No receipt content available'),
              ],
            ),
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
  }
}
