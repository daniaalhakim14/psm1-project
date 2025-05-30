import 'package:flutter/material.dart';
import 'package:fyp/View/accountpage.dart';
import 'package:fyp/View/expenseInput.dart';
import 'package:fyp/View/firstpage.dart';
import 'package:fyp/View/homepage.dart';
import 'package:provider/provider.dart';
import 'Model/signupLoginpage.dart';
import 'View/categorypage.dart';
import 'ViewModel/expense/expense_viewmodel.dart';
import 'ViewModel/signUpnLogIn/signUpnLogin_viewmodel.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => expenseViewModel()),
        ChangeNotifierProvider(create: (_) => signUpnLogin_viewmodel()),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: firstpage(),
    );
  }
}


