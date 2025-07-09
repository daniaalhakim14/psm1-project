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
  void initState() {
    super.initState();
    final userid =
        Provider.of<signUpnLogin_viewmodel>(context, listen: false,).userInfo!.id;
    final token =
        Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;
    if (token != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = Provider.of<TaxReliefViewModel>(
          context,
          listen: false,
        );
        viewModel.fetchTaxReliefCategory(userid, token);
        viewModel.fetchTotalCanClaim(token);
        viewModel.fetchTotalEligibleClaim(userid, token);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final viewModel = Provider.of<TaxReliefViewModel>(context, listen: false);
    viewModel.taxReliefCategory;

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
      body: Column(
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
            child: Consumer<TaxReliefViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.fetchingData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (viewModel.totalReliefList.isEmpty || viewModel.totalEligibleClaim.isEmpty) {
                  return Text("No data");
                }
                final totalRelief = viewModel.totalReliefList.isNotEmpty ? viewModel.totalReliefList.first.totalRelief : 0.0;
                final totalEligible = viewModel.totalEligibleClaim.isNotEmpty ? viewModel.totalEligibleClaim.first.claimedamount : 0.0;
                return Row(
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
                                Text('RM${totalEligible.toStringAsFixed(2)}'),
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
                                Text('RM${totalRelief.toStringAsFixed(2)}'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
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
          SizedBox(height: 8,),

          Expanded(
            child: Consumer<TaxReliefViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.fetchingData) {
                  return Center(child: CircularProgressIndicator());
                }

                if (viewModel.taxReliefCategory.isEmpty) {
                  return Center(
                    child: Text(
                      'No tax relief categories available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: viewModel.taxReliefCategory.length,
                  itemBuilder: (context, index) {
                    final category = viewModel.taxReliefCategory[index];

                    // Get the appropriate icon based on category type
                    String getIconPath(String categoryName) {
                      if (categoryName.toLowerCase().contains('individual')) {
                        return 'assets/Icons/man.png';
                      } else if (categoryName.toLowerCase().contains('medical') ||
                          categoryName.toLowerCase().contains('special')) {
                        return 'assets/Icons/medical.png';
                      } else if (categoryName.toLowerCase().contains('lifestyle')) {
                        return 'assets/Icons/lifestyle.png';
                      } else if (categoryName.toLowerCase().contains('child')) {
                        return 'assets/Icons/children.png';
                      } else if (categoryName.toLowerCase().contains('insurance')) {
                        return 'assets/Icons/secure.png';
                      } else {
                        return 'assets/Icons/no_picture.png'; // fallback icon
                      }
                    }

                    return TaxExemptCard(
                      imagePath: getIconPath(category.relieftype ?? ''),
                      title: category.relieftype ?? 'Unknown Category',
                      subtitle: 'Up to RM${category.amountCanClaim?.toStringAsFixed(2) ?? '0'}',
                      used: category.eligibleAmount ?? 0.0,
                      limit: category.amountCanClaim ?? 0.0,
                      onTap: () {
                        // Navigate to individual relief page
                        /*
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => individualRelief(
                              userInfo: widget.userInfo,
                              categoryId: category.id,
                              categoryName: category.categoryName,
                              maxAmount: category.maxAmount,
                              usedAmount: category.usedAmount,
                            ),
                          ),
                        );
                         */
                        final iconPath = getIconPath(category.relieftype ?? '');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => individualRelief(
                              categoryId: category.relieftypeid,
                              iconPath: iconPath,
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


        ],
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
}

class TaxExemptCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double used;
  final double limit;
  final VoidCallback onTap;

  const TaxExemptCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.used,
    required this.limit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final progressValue = limit > 0 ? used / limit : 0.0;

    return GestureDetector(
      onTap: onTap,
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
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFE3ECF5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      scale: 8,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.receipt,
                          size: 30,
                          color: Color(0xFF5A7BE7),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
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
                  '${used.toStringAsFixed(2)} used',
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
