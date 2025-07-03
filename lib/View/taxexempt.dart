import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/View/individualRelief.dart';
import 'package:fyp/ViewModel/expense/expense_viewmodel.dart';
import 'package:provider/provider.dart';
import '../Model/signupLoginpage.dart';
import '../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
import '../ViewModel/taxRelief/taxRelief_viewmodel.dart';
import 'accountpage.dart';
import 'comparepricepage.dart';
import 'homepage.dart';

class taxExempt extends StatefulWidget {
  final UserInfoModule userInfo;
  const taxExempt({super.key, required this.userInfo});

  @override
  State<taxExempt> createState() => _taxExemptState();
}

class _taxExemptState extends State<taxExempt> {
  @override
  void initState(){
    final token =
        Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
    if (token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = Provider.of<TaxReliefViewModel>(context, listen: false);
        viewModel.fetchTaxReliefs(token);
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Text(
          'Eligible Tax Relief',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF5A7BE7),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 8),
              // Top container
              Container(
                width: screenWidth * 0.98,
                height: screenHeight * 0.10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center row content
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/Icons/claim.png', scale: 12),
                            Column(
                              children: [
                                Text(
                                  'Total Eligible Claim:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('RM12,330.40'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: 8),
                    VerticalDivider(
                      width: 2,
                      thickness: 1,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8),
                    Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center row content
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/Icons/Remaining.png',
                              scale: 12,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Remaining Relief:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('RM28,169.60'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
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
                    Image.asset('assets/Icons/information.png', scale: 10),
                    SizedBox(width: 6),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Track your tax reliefs',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Automatically maps you receipts to\neligible tax relief',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8),
              Consumer<TaxReliefViewModel>(
                  builder: (contenxt,viewModel,child){
                    return Column(
                      children: [
                        _buildTaxExempt(
                          imagePath: 'assets/Icons/man.png',
                          title: 'Individual Relief',
                          subtitle: 'Up to RM9,000',
                          used: 750.00,
                          limit: 9000.00,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => individualRelief(),
                              ),
                            );
                          },
                        ),
                        _buildTaxExempt(
                          imagePath: 'assets/Icons/medical.png',
                          title: 'Medical & Special Needs',
                          subtitle: 'Up to RM10,000',
                          used: 2345.42,
                          limit: 10000.00,
                          onTap: () {
                            // another detail page maybe
                          },
                        ),
                        _buildTaxExempt(
                          imagePath: 'assets/Icons/lifestyle.png',
                          title: 'Lifestyle',
                          subtitle: 'Up to RM3,500',
                          used: 435.03,
                          limit: 3500.00,
                          onTap: () {
                            // another detail page maybe
                          },
                        ),
                        _buildTaxExempt(
                          imagePath: 'assets/Icons/children.png',
                          title: 'Child Relief',
                          subtitle: 'Up to RM8,000',
                          used: 3567.27,
                          limit: 8000.00,
                          onTap: () {
                            // another detail page maybe
                          },
                        ),
                        _buildTaxExempt(
                          imagePath: 'assets/Icons/secure.png',
                          title: 'Insurances',
                          subtitle: 'Up to RM10,000',
                          used: 5232.68,
                          limit: 10000.00,
                          onTap: () {
                            // another detail page maybe
                          },
                        ),
                      ],
                    );
                  })
              // Tax category

            ],
          ),
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
                  MaterialPageRoute(
                    builder: (context) => homepage(userInfo: widget.userInfo),
                  ),
                );
              },
              icon: Icon(CupertinoIcons.home, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            comparepricepage(userInfo: widget.userInfo),
                  ),
                );
              },
              icon: Icon(CupertinoIcons.search, size: 50, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.doc,
                size: 45,
                color: Color(0xFF5A7BE7),
              ),
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

  Widget _buildTaxExempt({
    required String imagePath,
    required String title,
    required String subtitle,
    required double used,
    required double limit,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: screenWidth * 0.98,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blueAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(imagePath, scale: 8),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${used.toStringAsFixed(2)} used',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: used / limit,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 5),
            const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'view details',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
