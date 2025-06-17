import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
class loadingPage extends StatefulWidget {
  const loadingPage({super.key});

  @override
  State<loadingPage> createState() => _loadingPageState();
}

class _loadingPageState extends State<loadingPage> {
  @override
  Widget build(BuildContext context) {
    const double _kSize = 100; // Size of the animation
    return Scaffold(
      backgroundColor: const Color(0xFF65ADAD), // Set your background color
      body: Center(
        child: LoadingAnimationWidget.discreteCircle(
          color: Color(0xFFFFA726), // Main color of the circle
          size: _kSize, // Size of the animation
          secondRingColor: Color(0xFFFF7043), // Color for the second ring
          thirdRingColor: Color(0xFFFFEB3B), // Color for the third ring
        ),
      ),
    );
  }
}
