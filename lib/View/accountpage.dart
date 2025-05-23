import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/View/homepage.dart';

import 'comparepricepage.dart';

class accountpage extends StatefulWidget {
  const accountpage({super.key});

  @override
  State<accountpage> createState() => _accountpageState();
}

class _accountpageState extends State<accountpage> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size; // Get screen size
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        title: Center(
          child: Text("Account", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            // Profile Picture
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.2,
                      decoration: BoxDecoration(
                        border: Border.all(width: 4, color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('lib/Stickers/profile_male.png'),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: screenHeight * -0.0325, // 1% of screen height
                      right: screenWidth * 0.045, // 1% of screen width
                      child: Container(
                        height: screenHeight * 0.12,
                        width: screenWidth * 0.12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 4, color: Colors.white),
                          color: Colors.blue,
                        ),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              "Danial Hakim Bin Norasmadi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("dhakim.dh.dh@gmail.com" + "|" + "+6013 348 3570"),
            SizedBox(height: 15),
            // Top Options tab
            Container(
              width: screenWidth * 0.85,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  AccountOptionTile(
                    iconPath: 'lib/Icons/edit_profile2.png',
                    label: 'Edit Profile Information',
                    onTap: () {
                      // navigate
                    },
                  ),
                  AccountOptionTile(
                    iconPath: 'lib/Icons/notification2.png',
                    label: 'Notification',
                    onTap: () {
                      // navigate
                    },
                  ),
                  AccountOptionTile(
                    iconPath: 'lib/Icons/feedback2.png',
                    label: 'Feeback',
                    onTap: () {
                      // toggle theme
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            // Middle Options tab
            Container(
              width: screenWidth * 0.85,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  AccountOptionTile(
                    iconPath: 'lib/Icons/budget3.png',
                    label: 'Monthly Budget Settings',
                    onTap: () {
                      // navigate
                    },
                  ),
                  AccountOptionTile(
                    iconPath: 'lib/Icons/preferences.png',
                    label: 'Preferences',
                    onTap: () {
                      // navigate
                    },
                  ),
                  AccountOptionTile(
                    iconPath: 'lib/Icons/report.png',
                    label: 'Generate Report',
                    onTap: () {
                      // toggle theme
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            // Bottom Options tab
            Container(
              width: screenWidth * 0.85,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  AccountOptionTile(
                    iconPath: 'lib/Icons/lock.png',
                    label: 'Change Password',
                    onTap: () {
                      // navigate
                    },
                  ),
                  AccountOptionTile(
                    iconPath: 'lib/Icons/family.png',
                    label: 'Family Sharing',
                    onTap: () {
                      // navigate
                    },
                  ),
                  AccountOptionTile(
                    iconPath: 'lib/Icons/delete.png',
                    label: 'Delete Account',
                    onTap: () {
                      // toggle theme
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            // Logout Button
            GestureDetector(
              onTap: () {
                // Logout
              },
              child: Container(
                width: screenWidth * 0.85,
                height: screenHeight * 0.05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.red,
                ),
                child: Center(
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
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
                  MaterialPageRoute(builder: (context) => homepage()),
                );
              },
              icon: Icon(CupertinoIcons.home, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => comparepricepage()),
                );
              },
              icon: Icon(CupertinoIcons.search, size: 50, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.doc, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
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

class AccountOptionTile extends StatefulWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const AccountOptionTile({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AccountOptionTile> createState() => _AccountOptionTileState();
}

class _AccountOptionTileState extends State<AccountOptionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap(); // Call the actual tap function
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isPressed ? Color(0xFFE3ECF5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(widget.iconPath, fit: BoxFit.contain),
            ),
            SizedBox(width: 12),
            Text(
              widget.label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
