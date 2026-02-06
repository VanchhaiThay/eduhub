import 'package:flutter/material.dart';

class MathPage extends StatefulWidget {
  const MathPage({super.key});

  @override
  State<MathPage> createState() => _MathPageState();
}

class _MathPageState extends State<MathPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Math"),
      ),
      body: const Center(
        child: Text(
          "Welcome to the Math page!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}