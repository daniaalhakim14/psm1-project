import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Model/signupLoginpage.dart';
import 'accountpage.dart';
import 'comparepricepage.dart';
import 'homepage.dart';
class taxExempt extends StatefulWidget {
  final  UserInfoModule userInfo;
  const taxExempt({super.key,required this.userInfo});

  @override
  State<taxExempt> createState() => _taxExemptState();
}

class _taxExemptState extends State<taxExempt> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFE3ECF5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF5A7BE7),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () { Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => homepage(userInfo:widget.userInfo,),),
              );},
              icon: Icon(CupertinoIcons.home, size: 45, color: Colors.black),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => comparepricepage(userInfo: widget.userInfo)),
                );
              },
              icon: Icon(CupertinoIcons.search, size: 50, color: Colors.black),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.doc, size: 45, color: Color(0xFF5A7BE7)),
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
