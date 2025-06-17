import 'package:flutter/material.dart';
import 'package:fyp/View/expenseInput.dart';
import 'package:fyp/View/firstpage.dart';
import 'package:fyp/View/selectitempage.dart';
import 'package:fyp/ViewModel/itemPricePremise/itemPrice_viewmodel.dart';
import 'package:provider/provider.dart';
import 'ViewModel/expense/expense_viewmodel.dart';
import 'ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => signUpnLogin_viewmodel()),
        ChangeNotifierProvider(create: (_) => expenseViewModel()),
        ChangeNotifierProvider(create: (_) => itemPrice_viewmodel())
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
      //home: firstpage(),
      home: expenseInput(),
    );
  }
}


