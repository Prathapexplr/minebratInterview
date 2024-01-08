import 'package:flutter/material.dart';

import 'input_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const InputScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: Image.asset('assets/minebrat_logo.jpeg'),
      ),
    );
  }
}
