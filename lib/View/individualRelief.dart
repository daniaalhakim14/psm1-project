import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class individualRelief extends StatefulWidget {
  const individualRelief({Key? key}) : super(key: key);

  @override
  State<individualRelief> createState() => _individualReliefState();
}

class _individualReliefState extends State<individualRelief> {
  double totalUsed = 5232.68;
  final double maxAllowed = 10000.0;

  final List<Map<String, dynamic>> reliefItems = [
    {
      'title': 'Alimony to Former Wife',
      'max': 4000.0,
      'used': 2000.0,
    },
    {
      'title': 'Individual & Dependent Relatives',
      'max': 9000.0,
      'used': 3232.68,
    },
    {
      'title': 'Education Fees (Self)',
      'max': 7000.0,
      'used': 0.0,
    },
    {
      'title': 'Disabled Individual',
      'max': 6000.0,
      'used': 0.0,
    },
    {
      'title': 'Disabled Spouse',
      'max': 5000.0,
      'used': 0.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Individual Relief",
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)
        ),
        backgroundColor: Color(0xFF5A7BE7),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 8),
              _buildDescriptionBox(),
              const SizedBox(height: 8),
              ...reliefItems.map((item) => _buildReliefCard(item)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
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
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/Icons/man.png'), // Replace with your image asset
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Type: Individual Relief", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("RM5000/RM10,000", style: TextStyle(color: Colors.grey)),
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

  Widget _buildDescriptionBox() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
            children: const [
              Text("📘 Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
                "Individual Relief refers to a set of tax reliefs available to individual taxpayers to reduce their chargeable income. It covers personal obligations, education, disabilities, and support for dependents or spouse.",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text("📌 Disclosures", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
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

  Widget _buildReliefCard(Map<String, dynamic> item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double percent = (item['used'] / item['max']).clamp(0.0, 1.0);

    return Container(
      width: screenWidth * 0.95,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Eligible: RM${item['max'].toStringAsFixed(2)}"),
              Text("Claimed: RM${item['used'].toStringAsFixed(2)}"),
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
            },
          ),
        ),
      ),
    );
  }
}
