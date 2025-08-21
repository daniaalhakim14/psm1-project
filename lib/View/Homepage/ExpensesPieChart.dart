import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ViewModel/signUpnLogin/signUpnLogin_viewmodel.dart';
class Expensespiechart extends StatefulWidget {
  const Expensespiechart({super.key});

  @override
  State<Expensespiechart> createState() => _ExpensespiechartState();
}

class _ExpensespiechartState extends State<Expensespiechart> {
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final token = Provider.of<signUpnLogin_viewmodel>(context, listen: false).authToken;

    });
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
