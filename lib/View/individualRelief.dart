import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import '../ViewModel/taxRelief/taxRelief_viewmodel.dart';

class individualRelief extends StatefulWidget {
  final int categoryId;
  final String iconPath;
  const individualRelief({required this.categoryId, required this.iconPath, Key? key}) : super(key: key);

  @override
  State<individualRelief> createState() => _individualReliefState();
}

class _individualReliefState extends State<individualRelief> {

  @override
  void initState() {
    super.initState();
    final userid = Provider.of<signUpnLogin_viewmodel>(context, listen: false,).userInfo!.id;
    final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
    if (token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = Provider.of<TaxReliefViewModel>(
          context,
          listen: false,
        );
        //viewModel.fetchTaxRelief(userid, widget.categoryId, token);
        viewModel.fetchReliefTypeInfo(widget.categoryId, token);
        viewModel.fetchReliefCategoryInfo(widget.categoryId, token);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A7BE7),
        automaticallyImplyLeading: true,
        title: Consumer<TaxReliefViewModel>(
          builder: (context, viewModel, _) {
            final reliefType = viewModel.reliefTypeInfo.isNotEmpty
                ? viewModel.reliefTypeInfo.first.relieftype ?? 'Tax Relief'
                : 'Tax Relief';

            return Text(
              reliefType,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                  final type = viewModel.reliefTypeInfo;
                  final category = viewModel.reliefCategoryInfo;
                  if (viewModel.fetchingData) {
                    return const CircularProgressIndicator();
                  } else if (type.isEmpty) {
                    return const Text("No tax relief data found.");
                  }

                  final totalUsed = type.fold(0.0, (sum, item) => sum + item.totalclaimedamount);
                  final maxAllowed = type.fold(0.0, (sum, item) => sum + item.totalRelief);
                  final reliefType = type.first.relieftype ?? 'Individual Relief';
                  final description = type.first.typeDescription ?? 'No description available';

                  return Column(
                    children: [
                      _buildSummaryCard(reliefType, maxAllowed, totalUsed),
                      const SizedBox(height: 8),
                      _buildDescriptionBox(description),
                      const SizedBox(height: 8),
                      ...category.map((item) => TaxReliefCard(
                        title: item.reliefcategory,
                        max: item.totalCategoryRelief,
                        used: item.totalCategoryClaimedAmount,
                      )),

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

  Widget _buildSummaryCard(String reliefType, double maxAllowed, double totalUsed) {
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
                    backgroundImage: AssetImage(widget.iconPath),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Type: $reliefType", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("RM${totalUsed.toStringAsFixed(2)} / RM${maxAllowed.toStringAsFixed(2)}", style: const TextStyle(color: Colors.grey)),
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
              const Text("📘 Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              const Text("📌 Disclosures", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
